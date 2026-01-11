import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/submit_issue_event.dart';
import 'package:grampulse/features/report/presentation/bloc/submit_issue_state.dart';

class SubmitIssueBloc extends Bloc<SubmitIssueEvent, SubmitIssueState> {
  final Connectivity _connectivity = Connectivity();
  final Uuid _uuid = Uuid();
  
  SubmitIssueBloc({
    required List<ReportMedia> media,
    required CategoryModel category,
    required String description,
    required int severity,
    required double latitude,
    required double longitude,
    required String address,
    ReliefRequest? reliefRequest,
  }) : super(const SubmitInitial()) {
    on<CheckConnection>(_onCheckConnection);
    on<SubmitIssue>(_onSubmitIssue);
    on<EditSection>(_onEditSection);
    on<CancelSubmission>(_onCancelSubmission);
    
    // Initialize with data and check connection
    _initializeState(
      media: media,
      category: category,
      description: description,
      severity: severity,
      latitude: latitude,
      longitude: longitude,
      address: address,
      reliefRequest: reliefRequest,
    );
  }
  
  Future<void> _initializeState({
    required List<ReportMedia> media,
    required CategoryModel category,
    required String description,
    required int severity,
    required double latitude,
    required double longitude,
    required String address,
    ReliefRequest? reliefRequest,
  }) async {
    // Check internet connection
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;
    
    // Emit initial ready state with all data
    emit(SubmitReady(
      media: media,
      category: category,
      description: description,
      severity: severity,
      latitude: latitude,
      longitude: longitude,
      address: address,
      reliefRequest: reliefRequest,
      isOnline: isOnline,
    ));
  }

  Future<void> _onCheckConnection(
    CheckConnection event,
    Emitter<SubmitIssueState> emit
  ) async {
    if (state is SubmitReady) {
      final currentState = state as SubmitReady;
      
      // Check internet connection
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      
      emit(currentState.copyWith(isOnline: isOnline));
    }
  }

  Future<void> _onSubmitIssue(
    SubmitIssue event,
    Emitter<SubmitIssueState> emit
  ) async {
    if (state is SubmitReady) {
      final currentState = state as SubmitReady;
      
      // Start validating
      emit(const SubmitValidating());
      
      try {
        // Simulate validation delay
        await Future.delayed(const Duration(seconds: 1));
        
        // Check if online or offline
        if (currentState.isOnline) {
          // Start uploading (online)
          emit(const SubmitUploading(progress: 0, total: 100));
          
          // Simulate media upload with progress
          for (int i = 1; i <= 3; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            emit(SubmitUploading(progress: i * 33, total: 100));
          }
          
          // Simulate successful submission
          final issueId = _uuid.v4();
          emit(SubmitSuccess(
            issueId: issueId,
            submittedAt: DateTime.now(),
          ));
        } else {
          // Submit offline (queue for later)
          final queuedId = _uuid.v4();
          emit(SubmitOfflineQueued(queuedId: queuedId));
        }
      } catch (e) {
        emit(SubmitError(message: 'Failed to submit issue: ${e.toString()}'));
      }
    }
  }

  Future<void> _onEditSection(
    EditSection event,
    Emitter<SubmitIssueState> emit
  ) async {
    // This is handled by the parent widget for navigation
  }

  Future<void> _onCancelSubmission(
    CancelSubmission event,
    Emitter<SubmitIssueState> emit
  ) async {
    // This is handled by the parent widget for navigation
  }
}
