import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_event.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_state.dart';

class MyReportsBloc extends Bloc<MyReportsEvent, MyReportsState> {
  final SupabaseService _supabase = SupabaseService();

  MyReportsBloc() : super(const ReportsInitial()) {
    on<LoadMyReports>(_onLoadMyReports);
    on<FilterByStatus>(_onFilterByStatus);
    on<LoadMoreReports>(_onLoadMoreReports);
    on<RefreshReports>(_onRefreshReports);
  }

  FutureOr<void> _onLoadMyReports(LoadMyReports event, Emitter<MyReportsState> emit) async {
    emit(const ReportsLoading());
    
    try {
      debugPrint('[MyReportsBloc] Loading reports from Supabase...');
      
      // Get current user ID
      final userId = _supabase.client.auth.currentUser?.id;
      final reports = await _fetchReportsFromSupabase(userId: userId);
      
      debugPrint('[MyReportsBloc] ✅ Loaded ${reports.length} reports');
      
      if (reports.isEmpty) {
        emit(const ReportsEmpty());
      } else {
        emit(ReportsLoaded(reports: reports, hasMore: reports.length >= 10));
      }
    } catch (e) {
      debugPrint('[MyReportsBloc] ❌ Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  FutureOr<void> _onFilterByStatus(FilterByStatus event, Emitter<MyReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      emit(const ReportsLoading());
      
      try {
        final userId = _supabase.client.auth.currentUser?.id;
        final filteredReports = await _fetchReportsFromSupabase(
          userId: userId,
          status: event.status == 'all' ? null : event.status,
        );
        
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
        // For now, set hasMore to false since we load all at once
        emit(currentState.copyWith(hasMore: false));
      } catch (e) {
        // Keep existing reports
      }
    }
  }

  FutureOr<void> _onRefreshReports(RefreshReports event, Emitter<MyReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      try {
        final userId = _supabase.client.auth.currentUser?.id;
        final reports = await _fetchReportsFromSupabase(
          userId: userId,
          status: currentState.selectedStatus == 'all' ? null : currentState.selectedStatus,
        );
        
        if (reports.isEmpty) {
          emit(const ReportsEmpty());
        } else {
          emit(currentState.copyWith(
            reports: reports,
            hasMore: reports.length >= 10,
          ));
        }
      } catch (e) {
        // Keep existing state
      }
    } else {
      add(const LoadMyReports());
    }
  }

  /// Fetch reports from Supabase
  Future<List<IssueModel>> _fetchReportsFromSupabase({
    String? userId,
    String? status,
  }) async {
    List<Map<String, dynamic>> incidentsData;
    
    if (userId != null) {
      incidentsData = await _supabase.getIncidentsByUser(userId);
    } else {
      incidentsData = await _supabase.getAllIncidents();
    }
    
    // Filter by status if provided
    if (status != null) {
      incidentsData = incidentsData.where((inc) => inc['status'] == status).toList();
    }
    
    return incidentsData.map((data) {
      return IssueModel(
        id: data['id'] as String? ?? '',
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        category: (data['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
        status: data['status'] as String? ?? 'submitted',
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? ''),
        location: data['location_address'] as String?,
        latitude: (data['location_lat'] as num?)?.toDouble(),
        longitude: (data['location_lng'] as num?)?.toDouble(),
        mediaUrls: [],
        severity: data['priority'] == 'high' ? 3 : (data['priority'] == 'medium' ? 2 : 1),
      );
    }).toList();
  }
}
