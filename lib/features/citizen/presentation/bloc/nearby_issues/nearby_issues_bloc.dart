import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import '../../../domain/models/issue_model.dart';

part 'nearby_issues_event.dart';
part 'nearby_issues_state.dart';

class NearbyIssuesBloc extends Bloc<NearbyIssuesEvent, NearbyIssuesState> {
  final SupabaseService _supabase = SupabaseService();
  
  NearbyIssuesBloc() : super(NearbyIssuesInitial()) {
    on<LoadNearbyIssues>(_onLoadNearbyIssues);
    on<RefreshNearbyIssues>(_onRefreshNearbyIssues);
    on<UpdateLocation>(_onUpdateLocation);
    on<FilterNearbyIssues>(_onFilterNearbyIssues);
  }

  Future<void> _onLoadNearbyIssues(
    LoadNearbyIssues event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      emit(NearbyIssuesLoading());
      debugPrint('[NearbyIssuesBloc] Loading issues from Supabase...');
      
      final issues = await _fetchIssuesFromSupabase();
      debugPrint('[NearbyIssuesBloc] ✅ Loaded ${issues.length} issues');
      
      emit(NearbyIssuesLoaded(issues: issues));
    } catch (error) {
      debugPrint('[NearbyIssuesBloc] ❌ Error: $error');
      emit(NearbyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onRefreshNearbyIssues(
    RefreshNearbyIssues event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NearbyIssuesLoaded) {
        emit(NearbyIssuesRefreshing(issues: currentState.issues));
        
        final issues = await _fetchIssuesFromSupabase();
        emit(NearbyIssuesLoaded(issues: issues));
      }
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NearbyIssuesLoaded) {
        emit(NearbyIssuesLoading());
        
        final issues = await _fetchIssuesFromSupabase();
        
        emit(NearbyIssuesLoaded(
          issues: issues,
          location: event.location,
        ));
      }
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onFilterNearbyIssues(
    FilterNearbyIssues event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NearbyIssuesLoaded) {
        emit(NearbyIssuesLoading());
        
        var issues = await _fetchIssuesFromSupabase();
        
        // Apply filters
        issues = issues.where((issue) {
          if (event.categoryFilter != null && 
              issue.category.toString() != event.categoryFilter) {
            return false;
          }
          if (event.statusFilter != null && 
              issue.status.toString() != event.statusFilter) {
            return false;
          }
          return true;
        }).toList();
        
        emit(NearbyIssuesLoaded(
          issues: issues,
          location: currentState.location,
          activeFilters: {
            if (event.categoryFilter != null)
              'category': event.categoryFilter,
            if (event.statusFilter != null)
              'status': event.statusFilter,
          },
        ));
      }
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
    }
  }
  
  /// Fetch real issues from Supabase
  Future<List<Issue>> _fetchIssuesFromSupabase() async {
    final incidentsData = await _supabase.getAllIncidents();
    
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
