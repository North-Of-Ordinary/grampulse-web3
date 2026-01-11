import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/report_details_event.dart';
import 'package:grampulse/features/report/presentation/bloc/report_details_state.dart';

class ReportDetailsBloc extends Bloc<ReportDetailsEvent, ReportDetailsState> {
  final IssueModel? initialIssue;
  
  ReportDetailsBloc({this.initialIssue}) : super(const DetailsInitial()) {
    on<LoadReportDetails>(_onLoadReportDetails);
    on<RefreshReportDetails>(_onRefreshReportDetails);
    on<ConfirmResolution>(_onConfirmResolution);
    on<ReopenIssue>(_onReopenIssue);
    on<RequestUpdate>(_onRequestUpdate);
    on<CancelReport>(_onCancelReport);
    on<ShareReport>(_onShareReport);
    
    // If we have an initial issue, load it immediately
    if (initialIssue != null) {
      add(LoadReportDetails(initialIssue!.id));
    }
  }

  FutureOr<void> _onLoadReportDetails(LoadReportDetails event, Emitter<ReportDetailsState> emit) async {
    emit(const DetailsLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would be a repository call
      final issue = initialIssue ?? await _fetchReportDetails(event.reportId);
      
      if (issue != null) {
        emit(DetailsLoaded(issue: issue));
      } else {
        emit(const DetailsError('Report not found'));
      }
    } catch (e) {
      emit(DetailsError(e.toString()));
    }
  }

  FutureOr<void> _onRefreshReportDetails(RefreshReportDetails event, Emitter<ReportDetailsState> emit) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;
      
      try {
        emit(currentState.copyWith(isSubmittingAction: true));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        // In a real app, this would be a repository call
        final updatedIssue = await _refreshReportDetails(currentState.issue.id);
        
        if (updatedIssue != null) {
          emit(DetailsLoaded(issue: updatedIssue));
        } else {
          emit(currentState.copyWith(isSubmittingAction: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmittingAction: false));
        emit(DetailsError(e.toString()));
      }
    }
  }

  FutureOr<void> _onConfirmResolution(ConfirmResolution event, Emitter<ReportDetailsState> emit) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;
      
      try {
        emit(currentState.copyWith(isSubmittingAction: true));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // In a real app, this would be a repository call
        final success = await _confirmResolution(
          currentState.issue.id,
          event.rating,
          event.feedback,
        );
        
        if (success) {
          // Create a new status update
          final newStatusUpdate = StatusUpdate(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: 'closed',
            timestamp: DateTime.now(),
            details: 'Citizen confirmed resolution. Rating: ${event.rating}/5',
          );
          
          // Update the issue with the new status
          final updatedIssue = currentState.issue.copyWith(
            status: 'closed',
            statusUpdates: [
              ...?currentState.issue.statusUpdates,
              newStatusUpdate,
            ],
          );
          
          emit(DetailsLoaded(issue: updatedIssue));
          emit(const DetailsActionSuccess(
            message: 'Resolution confirmed successfully!',
            action: 'confirm_resolution',
          ));
        } else {
          emit(currentState.copyWith(isSubmittingAction: false));
          emit(const DetailsError('Failed to confirm resolution'));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmittingAction: false));
        emit(DetailsError(e.toString()));
      }
    }
  }

  FutureOr<void> _onReopenIssue(ReopenIssue event, Emitter<ReportDetailsState> emit) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;
      
      try {
        emit(currentState.copyWith(isSubmittingAction: true));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // In a real app, this would be a repository call
        final success = await _reopenIssue(currentState.issue.id, event.reason);
        
        if (success) {
          // Create a new status update
          final newStatusUpdate = StatusUpdate(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: 'in_progress',
            timestamp: DateTime.now(),
            details: 'Issue reopened: ${event.reason}',
          );
          
          // Update the issue with the new status
          final updatedIssue = currentState.issue.copyWith(
            status: 'in_progress',
            statusUpdates: [
              ...?currentState.issue.statusUpdates,
              newStatusUpdate,
            ],
          );
          
          emit(DetailsLoaded(issue: updatedIssue));
          emit(const DetailsActionSuccess(
            message: 'Issue reopened successfully!',
            action: 'reopen',
          ));
        } else {
          emit(currentState.copyWith(isSubmittingAction: false));
          emit(const DetailsError('Failed to reopen issue'));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmittingAction: false));
        emit(DetailsError(e.toString()));
      }
    }
  }

  FutureOr<void> _onRequestUpdate(RequestUpdate event, Emitter<ReportDetailsState> emit) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;
      
      try {
        emit(currentState.copyWith(isSubmittingAction: true));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // In a real app, this would be a repository call
        final success = await _requestUpdate(currentState.issue.id, event.message);
        
        if (success) {
          emit(currentState.copyWith(isSubmittingAction: false));
          emit(const DetailsActionSuccess(
            message: 'Update request sent successfully!',
            action: 'request_update',
          ));
        } else {
          emit(currentState.copyWith(isSubmittingAction: false));
          emit(const DetailsError('Failed to send update request'));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmittingAction: false));
        emit(DetailsError(e.toString()));
      }
    }
  }

  FutureOr<void> _onCancelReport(CancelReport event, Emitter<ReportDetailsState> emit) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;
      
      try {
        emit(currentState.copyWith(isSubmittingAction: true));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // In a real app, this would be a repository call
        final success = await _cancelReport(currentState.issue.id, event.reason);
        
        if (success) {
          // Create a new status update
          final newStatusUpdate = StatusUpdate(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: 'cancelled',
            timestamp: DateTime.now(),
            details: 'Report cancelled by citizen: ${event.reason}',
          );
          
          // Update the issue with the new status
          final updatedIssue = currentState.issue.copyWith(
            status: 'cancelled',
            statusUpdates: [
              ...?currentState.issue.statusUpdates,
              newStatusUpdate,
            ],
          );
          
          emit(DetailsLoaded(issue: updatedIssue));
          emit(const DetailsActionSuccess(
            message: 'Report cancelled successfully!',
            action: 'cancel',
          ));
        } else {
          emit(currentState.copyWith(isSubmittingAction: false));
          emit(const DetailsError('Failed to cancel report'));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmittingAction: false));
        emit(DetailsError(e.toString()));
      }
    }
  }

  FutureOr<void> _onShareReport(ShareReport event, Emitter<ReportDetailsState> emit) async {
    // This would typically use a platform-specific share functionality
    // For now, just emit a success message
    if (state is DetailsLoaded) {
      emit(const DetailsActionSuccess(
        message: 'Report shared successfully!',
        action: 'share',
      ));
    }
  }

  // Mock data methods (in a real app, these would be repository calls)
  Future<IssueModel?> _fetchReportDetails(String reportId) async {
    // This would be a repository call in a real app
    return initialIssue;
  }

  Future<IssueModel?> _refreshReportDetails(String reportId) async {
    // This would be a repository call in a real app
    return initialIssue;
  }

  Future<bool> _confirmResolution(String reportId, int rating, String feedback) async {
    // This would be a repository call in a real app
    return true;
  }

  Future<bool> _reopenIssue(String reportId, String reason) async {
    // This would be a repository call in a real app
    return true;
  }

  Future<bool> _requestUpdate(String reportId, String message) async {
    // This would be a repository call in a real app
    return true;
  }

  Future<bool> _cancelReport(String reportId, String reason) async {
    // This would be a repository call in a real app
    return true;
  }
}
