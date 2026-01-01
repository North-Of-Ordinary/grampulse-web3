import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class CaptureMediaState extends Equatable {
  const CaptureMediaState();

  @override
  List<Object?> get props => [];
}

class CaptureInitial extends CaptureMediaState {
  const CaptureInitial();
}

class CaptureLoading extends CaptureMediaState {
  const CaptureLoading();
}

class CaptureReady extends CaptureMediaState {
  final bool isFlashOn;
  final List<ReportMedia> capturedMedia;
  final File? lastCapturedImage;
  final bool isRecording;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final String? locationError;

  const CaptureReady({
    this.isFlashOn = false,
    this.capturedMedia = const [],
    this.lastCapturedImage,
    this.isRecording = false,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.locationError,
  });

  @override
  List<Object?> get props => [
    isFlashOn, 
    capturedMedia, 
    lastCapturedImage?.path, 
    isRecording, 
    locationAddress, 
    latitude, 
    longitude, 
    locationError
  ];

  CaptureReady copyWith({
    bool? isFlashOn,
    List<ReportMedia>? capturedMedia,
    File? lastCapturedImage,
    bool? isRecording,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? locationError,
  }) {
    return CaptureReady(
      isFlashOn: isFlashOn ?? this.isFlashOn,
      capturedMedia: capturedMedia ?? this.capturedMedia,
      lastCapturedImage: lastCapturedImage ?? this.lastCapturedImage,
      isRecording: isRecording ?? this.isRecording,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationError: locationError ?? this.locationError,
    );
  }

  bool get canProceed => capturedMedia.isNotEmpty && latitude != null && longitude != null;
  
  bool get isLocationAvailable => latitude != null && longitude != null && locationAddress != null;
  
  int get mediaCount => capturedMedia.length;
}

class CaptureTaken extends CaptureMediaState {
  final File image;

  const CaptureTaken({required this.image});

  @override
  List<Object> get props => [image.path];
}

class CaptureError extends CaptureMediaState {
  final String message;

  const CaptureError({required this.message});

  @override
  List<Object> get props => [message];
}
