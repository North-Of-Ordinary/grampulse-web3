import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import '../../../domain/models/issue_model.dart';
part 'my_issues_event.dart';
part 'my_issues_state.dart';

class MyIssuesBloc extends Bloc<MyIssuesEvent, MyIssuesState> {
  final SupabaseService _supabase = SupabaseService();
  
  MyIssuesBloc() : super(MyIssuesInitial()) {
    on<LoadMyIssues>(_onLoadMyIssues);
    on<RefreshMyIssues>(_onRefreshMyIssues);
    on<FilterMyIssues>(_onFilterMyIssues);
  }

  Future<void> _onLoadMyIssues(
    LoadMyIssues event,
    Emitter<MyIssuesState> emit,
  ) async {
    try {
      emit(MyIssuesLoading());
      debugPrint('[MyIssuesBloc] Loading user issues from Supabase...');
      
      // Get current user ID from Supabase auth or session
      final userId = _supabase.client.auth.currentUser?.id;
      final issues = await _fetchIssuesFromSupabase(userId: userId);
      
      debugPrint('[MyIssuesBloc] ✅ Loaded ${issues.length} issues');
      
      emit(MyIssuesLoaded(
        reportedIssues: issues,
        upvotedIssues: [], // TODO: Implement upvoted issues tracking
      ));
    } catch (error) {
      debugPrint('[MyIssuesBloc] ❌ Error: $error');
      emit(MyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onRefreshMyIssues(
    RefreshMyIssues event,
    Emitter<MyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is MyIssuesLoaded) {
        emit(MyIssuesRefreshing(
          reportedIssues: currentState.reportedIssues,
          upvotedIssues: currentState.upvotedIssues,
        ));
        
        final userId = _supabase.client.auth.currentUser?.id;
        final issues = await _fetchIssuesFromSupabase(userId: userId);
        
        emit(MyIssuesLoaded(
          reportedIssues: issues,
          upvotedIssues: [],
        ));
      }
    } catch (error) {
      emit(MyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onFilterMyIssues(
    FilterMyIssues event,
    Emitter<MyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is MyIssuesLoaded) {
        emit(MyIssuesLoading());
        
        final userId = _supabase.client.auth.currentUser?.id;
        var issues = await _fetchIssuesFromSupabase(userId: userId);
        
        // Apply filters
        issues = issues.where((issue) {
          if (event.statusFilter != null && 
              issue.status.toString() != event.statusFilter.toString()) {
            return false;
          }
          if (event.categoryFilter != null && 
              issue.category.toString() != event.categoryFilter.toString()) {
            return false;
          }
          return true;
        }).toList();
        
        emit(MyIssuesLoaded(
          reportedIssues: issues,
          upvotedIssues: [],
          activeFilters: {
            if (event.categoryFilter != null)
              'category': event.categoryFilter,
            if (event.statusFilter != null)
              'status': event.statusFilter,
          },
        ));
      }
    } catch (error) {
      emit(MyIssuesError(message: error.toString()));
    }
  }
  
  /// Fetch real issues from Supabase
  Future<List<Issue>> _fetchIssuesFromSupabase({String? userId}) async {
    final incidentsData = userId != null 
        ? await _supabase.getIncidentsByUser(userId)
        : await _supabase.getAllIncidents();
    
    return incidentsData.map((data) {
      final category = (data['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other';
      final status = data['status'] as String? ?? 'submitted';
      
      return Issue(
        id: data['id'] as String? ?? '',
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        category: _mapCategory(category),
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? '') ?? DateTime.now(),
        status: _mapStatus(status),
        priority: _mapPriority(data['priority'] as String?),
        location: GeoLocation(
          latitude: (data['location_lat'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['location_lng'] as num?)?.toDouble() ?? 0.0,
          address: data['location_address'] as String? ?? '',
          locality: '',
          adminArea: '',
          pinCode: '',
        ),
        reporterId: data['user_id'] as String? ?? '',
        reporterName: (data['users'] as Map<String, dynamic>?)?['name'] as String? ?? 'Anonymous',
        mediaUrls: [],
        upvotes: 0,
        adminLevel: AdminLevel.panchayat,
        assignedDepartment: (data['departments'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        isPublic: data['is_public'] as bool? ?? true,
        updates: [],
      );
    }).toList();
  }
  
  IssueCategory _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electricity': return IssueCategory.electricity;
      case 'water supply': return IssueCategory.waterSupply;
      case 'roads': case 'road damage': return IssueCategory.roadDamage;
      case 'sanitation': return IssueCategory.sanitation;
      case 'health': case 'healthcare': return IssueCategory.healthcare;
      case 'education': return IssueCategory.education;
      case 'public property': return IssueCategory.publicProperty;
      default: return IssueCategory.other;
    }
  }
  
  IssueStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted': case 'new': return IssueStatus.new_issue;
      case 'in_progress': return IssueStatus.in_progress;
      case 'resolved': return IssueStatus.resolved;
      case 'verified': return IssueStatus.verified;
      case 'overdue': return IssueStatus.overdue;
      default: return IssueStatus.new_issue;
    }
  }
  
  IssuePriority _mapPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high': return IssuePriority.high;
      case 'medium': return IssuePriority.medium;
      case 'low': return IssuePriority.low;
      default: return IssuePriority.medium;
    }
  }
}
