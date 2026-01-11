import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_event.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_state.dart';

class MyReportsBloc extends Bloc<MyReportsEvent, MyReportsState> {
  // This would typically come from a repository
  final List<IssueModel> _mockReports = [
    // Placeholder for mock data
  ];

  MyReportsBloc() : super(const ReportsInitial()) {
    on<LoadMyReports>(_onLoadMyReports);
    on<FilterByStatus>(_onFilterByStatus);
    on<LoadMoreReports>(_onLoadMoreReports);
    on<RefreshReports>(_onRefreshReports);
  }

  FutureOr<void> _onLoadMyReports(LoadMyReports event, Emitter<MyReportsState> emit) async {
    emit(const ReportsLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would be a repository call
      final reports = _fetchReports();
      
      if (reports.isEmpty) {
        emit(const ReportsEmpty());
      } else {
        emit(ReportsLoaded(reports: reports, hasMore: reports.length >= 10));
      }
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  FutureOr<void> _onFilterByStatus(FilterByStatus event, Emitter<MyReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      emit(ReportsLoading());
      
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Filter reports based on status
        final filteredReports = _fetchReports(status: event.status);
        
        if (filteredReports.isEmpty) {
          emit(const ReportsEmpty());
        } else {
          emit(currentState.copyWith(
            reports: filteredReports,
            selectedStatus: event.status,
          ));
        }
      } catch (e) {
        emit(ReportsError(e.toString()));
      }
    }
  }

  FutureOr<void> _onLoadMoreReports(LoadMoreReports event, Emitter<MyReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        // In a real app, we'd use pagination parameters
        final moreReports = _fetchMoreReports(currentState.reports.length);
        
        if (moreReports.isNotEmpty) {
          emit(currentState.copyWith(
            reports: [...currentState.reports, ...moreReports],
            hasMore: moreReports.length >= 5, // Assuming page size of 5
          ));
        } else {
          emit(currentState.copyWith(hasMore: false));
        }
      } catch (e) {
        // Keep existing reports but show error
        // We could also add an error banner to the UI
      }
    }
  }

  FutureOr<void> _onRefreshReports(RefreshReports event, Emitter<MyReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        // In a real app, this would be a repository call with refresh parameter
        final reports = _fetchReports(status: currentState.selectedStatus);
        
        if (reports.isEmpty) {
          emit(const ReportsEmpty());
        } else {
          emit(currentState.copyWith(
            reports: reports,
            hasMore: reports.length >= 10,
          ));
        }
      } catch (e) {
        // Keep existing state but show error
        // We could also add an error banner to the UI
      }
    } else {
      add(const LoadMyReports());
    }
  }

  // Mock data methods (in a real app, these would be repository calls)
  List<IssueModel> _fetchReports({String status = 'all'}) {
    if (status == 'all') {
      return _mockReports;
    } else {
      return _mockReports.where((report) => report.status == status).toList();
    }
  }

  List<IssueModel> _fetchMoreReports(int offset) {
    // Simulate pagination
    if (offset >= _mockReports.length) {
      return [];
    }
    
    final end = (offset + 5) > _mockReports.length ? _mockReports.length : offset + 5;
    return _mockReports.sublist(offset, end);
  }
}
