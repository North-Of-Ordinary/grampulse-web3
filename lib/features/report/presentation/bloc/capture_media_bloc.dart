import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grampulse/features/report/presentation/bloc/capture_media_event.dart';
import 'package:grampulse/features/report/presentation/bloc/capture_media_state.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

class CaptureMediaBloc extends Bloc<CaptureMediaEvent, CaptureMediaState> {
  CameraController? _cameraController;
    final Record _audioRecorder = Record();
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = Uuid();
  
  // Public getter for camera controller
  CameraController? get cameraController => _cameraController;
  
  CaptureMediaBloc() : super(const CaptureInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<ToggleFlash>(_onToggleFlash);
    on<CaptureImage>(_onCaptureImage);
    on<SelectFromGallery>(_onSelectFromGallery);
    on<AddMedia>(_onAddMedia);
    on<RemoveMedia>(_onRemoveMedia);
    on<StartVoiceRecording>(_onStartVoiceRecording);
    on<StopVoiceRecording>(_onStopVoiceRecording);
    on<RefreshLocation>(_onRefreshLocation);
    on<ValidateAndProceed>(_onValidateAndProceed);
    on<DisposeCamera>(_onDisposeCamera);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event, 
    Emitter<CaptureMediaState> emit
  ) async {
    emit(const CaptureLoading());
    
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(const CaptureError(message: 'No cameras available'));
        return;
      }
      
      // Initialize with the first (back) camera
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize the camera controller
      await _cameraController!.initialize();
      
      // Get location
      Position? position;
      String? address;
      String? locationError;
      
      try {
        position = await _getCurrentLocation();
        if (position != null) {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            address = _formatAddress(place);
          }
        }
      } catch (e) {
        locationError = 'Could not get location';
      }
      
      // Emit ready state
      emit(CaptureReady(
        isFlashOn: false,
        locationAddress: address,
        latitude: position?.latitude,
        longitude: position?.longitude,
        locationError: locationError,
      ));
    } catch (e) {
      emit(CaptureError(message: 'Error initializing camera: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFlash(
    ToggleFlash event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady && _cameraController != null) {
      final currentState = state as CaptureReady;
      final newFlashState = !currentState.isFlashOn;
      
      try {
        await _cameraController!.setFlashMode(
          newFlashState ? FlashMode.torch : FlashMode.off
        );
        
        emit(currentState.copyWith(isFlashOn: newFlashState));
      } catch (e) {
        emit(CaptureError(message: 'Failed to toggle flash: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCaptureImage(
    CaptureImage event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady && _cameraController != null) {
      try {
        // Take picture
        final xFile = await _cameraController!.takePicture();
        final imageFile = File(xFile.path);
        
        // Compress the image
        final compressedFile = await _compressImage(imageFile);
        
        // Emit captured state briefly to show feedback
        emit(CaptureTaken(image: compressedFile));
        
        // Add media to list
        add(AddMedia(file: compressedFile, type: MediaType.image));
      } catch (e) {
        emit(CaptureError(message: 'Failed to take picture: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSelectFromGallery(
    SelectFromGallery event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      try {
        // Pick image from gallery
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        
        if (pickedFile != null) {
          final imageFile = File(pickedFile.path);
          
          // Compress the image
          final compressedFile = await _compressImage(imageFile);
          
          // Add media to list
          add(AddMedia(file: compressedFile, type: MediaType.image));
        }
      } catch (e) {
        emit(CaptureError(message: 'Failed to pick image: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddMedia(
    AddMedia event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      final currentState = state as CaptureReady;
      final existingMedia = List<ReportMedia>.from(currentState.capturedMedia);
      
      // Check if we already have maximum media items
      if (existingMedia.length >= 4) {
        emit(CaptureError(message: 'Maximum 4 media items allowed'));
        emit(currentState); // Return to previous state
        return;
      }
      
      // Create new media item
      final newMedia = ReportMedia(
        id: _uuid.v4(),
        file: event.file,
        fileType: event.type,
        capturedAt: DateTime.now(),
      );
      
      // Add to list
      existingMedia.add(newMedia);
      
      // Update state
      emit(currentState.copyWith(
        capturedMedia: existingMedia,
        lastCapturedImage: event.type == MediaType.image ? event.file : null,
      ));
    }
  }

  Future<void> _onRemoveMedia(
    RemoveMedia event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      final currentState = state as CaptureReady;
      final existingMedia = List<ReportMedia>.from(currentState.capturedMedia);
      
      // Remove media with matching ID
      existingMedia.removeWhere((media) => media.id == event.mediaId);
      
      // Update state
      emit(currentState.copyWith(capturedMedia: existingMedia));
    }
  }

  Future<void> _onStartVoiceRecording(
    StartVoiceRecording event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      final currentState = state as CaptureReady;
      
      try {
        // Check and request permissions
        if (await _audioRecorder.hasPermission()) {
          // Get temporary directory
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/${_uuid.v4()}.m4a';
          
          // Start recording
          await _audioRecorder.start(path: filePath);
          
          // Update state to show recording in progress
          emit(currentState.copyWith(isRecording: true));
        } else {
          emit(const CaptureError(message: 'Microphone permission denied'));
          emit(currentState); // Return to previous state
        }
      } catch (e) {
        emit(CaptureError(message: 'Failed to start recording: ${e.toString()}'));
        emit(currentState); // Return to previous state
      }
    }
  }

  Future<void> _onStopVoiceRecording(
    StopVoiceRecording event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      final currentState = state as CaptureReady;
      
      try {
        // Stop recording and get file path
        final filePath = await _audioRecorder.stop();
        
        if (filePath != null) {
          // Add audio to media list
          add(AddMedia(file: File(filePath), type: MediaType.audio));
        }
        
        // Update state
        emit(currentState.copyWith(isRecording: false));
      } catch (e) {
        emit(CaptureError(message: 'Failed to stop recording: ${e.toString()}'));
        emit(currentState.copyWith(isRecording: false));
      }
    }
  }

  Future<void> _onRefreshLocation(
    RefreshLocation event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      final currentState = state as CaptureReady;
      
      emit(currentState.copyWith(
        locationAddress: null,
        locationError: null
      ));
      
      try {
        // Get current location
        final position = await _getCurrentLocation();
        if (position != null) {
          // Get address from coordinates
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final address = _formatAddress(place);
            
            // Update state with new location
            emit(currentState.copyWith(
              locationAddress: address,
              latitude: position.latitude,
              longitude: position.longitude,
              locationError: null,
            ));
          } else {
            emit(currentState.copyWith(
              locationError: 'Could not determine address',
              latitude: position.latitude,
              longitude: position.longitude,
            ));
          }
        }
      } catch (e) {
        emit(currentState.copyWith(
          locationError: 'Failed to get location'
        ));
      }
    }
  }

  Future<void> _onValidateAndProceed(
    ValidateAndProceed event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (state is CaptureReady) {
      final currentState = state as CaptureReady;
      
      if (currentState.capturedMedia.isEmpty) {
        emit(const CaptureError(message: 'Please capture at least one photo'));
        emit(currentState); // Return to previous state
        return;
      }
      
      if (!currentState.isLocationAvailable) {
        emit(const CaptureError(message: 'Location information is required'));
        emit(currentState); // Return to previous state
        return;
      }
      
      // If all validations pass, we can proceed (handled by parent)
    }
  }

  Future<void> _onDisposeCamera(
    DisposeCamera event, 
    Emitter<CaptureMediaState> emit
  ) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
    
    emit(const CaptureInitial());
  }

  // Helper methods
  Future<Position?> _getCurrentLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }

  String _formatAddress(Placemark place) {
    return [
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ]
        .where((item) => item != null && item.isNotEmpty)
        .join(', ');
  }

  Future<File> _compressImage(File file) async {
    // Create output file path
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${_uuid.v4()}.jpg';
    
    // Compress image
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      rotate: 0,
    );
    
    // Return compressed file or original if compression failed
    return result != null ? File(result.path) : file;
  }
  
  @override
  Future<void> close() {
    if (_cameraController != null) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    return super.close();
  }
}
