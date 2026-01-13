import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/supabase_service.dart';

// Events
abstract class OfficerDashboardEvent extends Equatable {
  const OfficerDashboardEvent();
  @override
  List<Object> get props => [];
}

class LoadOfficerDashboard extends OfficerDashboardEvent {
  const LoadOfficerDashboard();
}

class RefreshOfficerDashboard extends OfficerDashboardEvent {
  const RefreshOfficerDashboard();
}

class UpdateIssueStatus extends OfficerDashboardEvent {
  final String issueId;
  final String newStatus;
  const UpdateIssueStatus(this.issueId, this.newStatus);
  @override
  List<Object> get props => [issueId, newStatus];
}

// States
abstract class OfficerDashboardState extends Equatable {
  const OfficerDashboardState();
  @override
  List<Object> get props => [];
}

class OfficerDashboardInitial extends OfficerDashboardState {
  const OfficerDashboardInitial();
}

class OfficerDashboardLoading extends OfficerDashboardState {
  const OfficerDashboardLoading();
}

class OfficerDashboardLoaded extends OfficerDashboardState {
  final OfficerStats stats;
  final List<Issue> pendingIssues;
  final List<Issue> inProgressIssues;
  const OfficerDashboardLoaded({required this.stats, required this.pendingIssues, required this.inProgressIssues});
  @override
  List<Object> get props => [stats, pendingIssues, inProgressIssues];
}

class OfficerDashboardError extends OfficerDashboardState {
  final String message;
  const OfficerDashboardError(this.message);
  @override
  List<Object> get props => [message];
}

// Data Models
class OfficerStats {
  final int totalAssigned;
  final int pendingReview;
  final int inProgress;
  final int resolvedThisWeek;
  final double avgResolutionTime;
  
  const OfficerStats({
    required this.totalAssigned,
    required this.pendingReview,
    required this.inProgress,
    required this.resolvedThisWeek,
    required this.avgResolutionTime,
  });
}

class Issue {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String priority;
  final String status;
  final String reportedBy;
  final DateTime reportedAt;
  final String? assignedTo;
  final DateTime? deadline;
  
  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.reportedBy,
    required this.reportedAt,
    this.assignedTo,
    this.deadline,
  });
}

// BLoC
class OfficerDashboardBloc extends Bloc<OfficerDashboardEvent, OfficerDashboardState> {
  final SupabaseService _supabase = SupabaseService();
  
  OfficerDashboardBloc() : super(const OfficerDashboardInitial()) {
    on<LoadOfficerDashboard>(_onLoadDashboard);
    on<RefreshOfficerDashboard>(_onRefreshDashboard);
    on<UpdateIssueStatus>(_onUpdateIssueStatus);
  }

  Future<void> _onLoadDashboard(LoadOfficerDashboard event, Emitter<OfficerDashboardState> emit) async {
    emit(const OfficerDashboardLoading());
    
    try {
      debugPrint('[OfficerDashboardBloc] Loading from Supabase...');
      
      // Fetch real incidents from Supabase
      final incidents = await _supabase.getAllIncidents();
      final incidentStats = await _supabase.getIncidentStatistics();
      
      // Calculate stats from real data
      final stats = OfficerStats(
        totalAssigned: incidents.length,
        pendingReview: incidentStats['new'] ?? 0,
        inProgress: incidentStats['in_progress'] ?? 0,
        resolvedThisWeek: incidentStats['resolved'] ?? 0,
        avgResolutionTime: 2.5, // TODO: Calculate from real data
      );
      
      // Convert incidents to Issue objects
      final pendingIssues = incidents
          .where((inc) => inc['status'] == 'submitted' || inc['status'] == 'new')
          .map((inc) => _mapIncidentToIssue(inc))
          .toList();
      
      final inProgressIssues = incidents
          .where((inc) => inc['status'] == 'in_progress')
          .map((inc) => _mapIncidentToIssue(inc))
          .toList();
      
      debugPrint('[OfficerDashboardBloc] ✅ Loaded ${pendingIssues.length} pending, ${inProgressIssues.length} in-progress');
      
      emit(OfficerDashboardLoaded(
        stats: stats,
        pendingIssues: pendingIssues,
        inProgressIssues: inProgressIssues,
      ));
    } catch (e) {
      debugPrint('[OfficerDashboardBloc] ❌ Error: $e');
      emit(OfficerDashboardError(e.toString()));
    }
  }
  
  Issue _mapIncidentToIssue(Map<String, dynamic> inc) {
    return Issue(
      id: inc['id'] as String? ?? '',
      title: inc['title'] as String? ?? '',
      description: inc['description'] as String? ?? '',
      category: (inc['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
      location: inc['location_address'] as String? ?? 'Unknown',
      priority: _mapPriority(inc['severity'] as int?),
      status: _mapStatus(inc['status'] as String?),
      reportedBy: (inc['users'] as Map<String, dynamic>?)?['name'] as String? ?? 'Citizen Report',
      reportedAt: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
      assignedTo: inc['assigned_officer_id'] as String?,
      deadline: inc['deadline'] != null 
          ? DateTime.tryParse(inc['deadline'] as String) 
          : DateTime.now().add(const Duration(days: 7)),
    );
  }
  
  String _mapPriority(int? severity) {
    switch (severity) {
      case 3: return 'High';
      case 2: return 'Medium';
      default: return 'Low';
    }
  }
  
  String _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'submitted': case 'new': return 'Pending Review';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return 'Pending Review';
    }
  }

  Future<void> _onRefreshDashboard(RefreshOfficerDashboard event, Emitter<OfficerDashboardState> emit) async {
    // Re-load from Supabase
    add(const LoadOfficerDashboard());
  }

  Future<void> _onUpdateIssueStatus(UpdateIssueStatus event, Emitter<OfficerDashboardState> emit) async {
    try {
      debugPrint('[OfficerDashboardBloc] Updating issue ${event.issueId} to ${event.newStatus}');
      
      // Update in Supabase
      await _supabase.updateIncidentStatus(event.issueId, event.newStatus);
      
      // Reload dashboard
      add(const LoadOfficerDashboard());
    } catch (e) {
      debugPrint('[OfficerDashboardBloc] ❌ Update error: $e');
      emit(OfficerDashboardError('Failed to update issue: $e'));
    }
  }
}
