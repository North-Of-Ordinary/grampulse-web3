import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/describe_issue_event.dart';
import 'package:grampulse/features/report/presentation/bloc/describe_issue_state.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt; // Temporarily disabled

class DescribeIssueBloc extends Bloc<DescribeIssueEvent, DescribeIssueState> {
  // final stt.SpeechToText _speechToText = stt.SpeechToText(); // Temporarily disabled
  
  DescribeIssueBloc({
    required double initialLatitude,
    required double initialLongitude,
    required String initialAddress,
  }) : super(const DescribeInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<UpdateCategory>(_onUpdateCategory);
    on<UpdateDescription>(_onUpdateDescription);
    on<UpdateSeverity>(_onUpdateSeverity);
    on<UpdateLocation>(_onUpdateLocation);
    on<ConvertVoiceToText>(_onConvertVoiceToText);
    on<ValidateAndProceed>(_onValidateAndProceed);
    
    // Initialize with load categories
    add(const LoadCategories());
  }

  Future<void> _onLoadCategories(
    LoadCategories event, 
    Emitter<DescribeIssueState> emit
  ) async {
    emit(const DescribeUpdating());
    
    try {
      // Get predefined categories
      final categories = CategoryModel.defaultCategories;
      
      // Get the initial state from constructor parameters
      if (state is DescribeInitial) {
        final initialState = DescribeReady(
          categories: categories,
          latitude: 0.0, // Will be updated from constructor
          longitude: 0.0, // Will be updated from constructor
          address: '', // Will be updated from constructor
        );
        emit(initialState);
      } else if (state is DescribeReady) {
        final currentState = state as DescribeReady;
        emit(currentState.copyWith(categories: categories));
      }
    } catch (e) {
      emit(DescribeError(message: 'Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event, 
    Emitter<DescribeIssueState> emit
  ) async {
    if (state is DescribeReady) {
      final currentState = state as DescribeReady;
      emit(currentState.copyWith(selectedCategoryId: event.categoryId));
    }
  }

  Future<void> _onUpdateDescription(
    UpdateDescription event, 
    Emitter<DescribeIssueState> emit
  ) async {
    if (state is DescribeReady) {
      final currentState = state as DescribeReady;
      emit(currentState.copyWith(description: event.description));
    }
  }

  Future<void> _onUpdateSeverity(
    UpdateSeverity event, 
    Emitter<DescribeIssueState> emit
  ) async {
    if (state is DescribeReady) {
      final currentState = state as DescribeReady;
      emit(currentState.copyWith(severity: event.severity));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event, 
    Emitter<DescribeIssueState> emit
  ) async {
    if (state is DescribeReady) {
      final currentState = state as DescribeReady;
      emit(currentState.copyWith(
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
      ));
    }
  }

  Future<void> _onConvertVoiceToText(
    ConvertVoiceToText event, 
    Emitter<DescribeIssueState> emit
  ) async {
    if (state is DescribeReady) {
      final currentState = state as DescribeReady;
      
      // Set processing flag
      emit(currentState.copyWith(isProcessingVoice: true));
      
      try {
        // Speech recognition temporarily disabled
        // Placeholder for speech to text conversion
        // In a real app, you would process the audio file here
        // This is a simplified version that simulates processing
        await Future.delayed(const Duration(seconds: 2));
        
        // Add transcribed text to description
        final currentDescription = currentState.description;
        const transcribedText = "This is a sample voice transcription. "
            "Replace this with actual transcription from the audio file.";
        
        final updatedDescription = currentDescription.isEmpty 
            ? transcribedText
            : "$currentDescription\n\n$transcribedText";
        
        emit(currentState.copyWith(
          description: updatedDescription,
          isProcessingVoice: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isProcessingVoice: false));
        emit(DescribeError(message: 'Failed to process voice: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  Future<void> _onValidateAndProceed(
    ValidateAndProceed event, 
    Emitter<DescribeIssueState> emit
  ) async {
    if (state is DescribeReady) {
      final currentState = state as DescribeReady;
      
      if (currentState.selectedCategoryId == null) {
        emit(const DescribeError(message: 'Please select a category'));
        emit(currentState);
        return;
      }
      
      if (currentState.description.isEmpty) {
        emit(const DescribeError(message: 'Please enter a description'));
        emit(currentState);
        return;
      }
      
      if (currentState.description.length < 10) {
        emit(const DescribeError(message: 'Description is too short'));
        emit(currentState);
        return;
      }
      
      // If all validations pass, we can proceed (handled by parent)
    }
  }
}
