import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  OfficerDashboardBloc() : super(const OfficerDashboardInitial()) {
    on<LoadOfficerDashboard>(_onLoadDashboard);
    on<RefreshOfficerDashboard>(_onRefreshDashboard);
    on<UpdateIssueStatus>(_onUpdateIssueStatus);
  }

  Future<void> _onLoadDashboard(LoadOfficerDashboard event, Emitter<OfficerDashboardState> emit) async {
    emit(const OfficerDashboardLoading());
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      const stats = OfficerStats(
        totalAssigned: 45,
        pendingReview: 12,
        inProgress: 8,
        resolvedThisWeek: 15,
        avgResolutionTime: 2.5,
      );
      
      final pendingIssues = [
        Issue(
          id: '1',
          title: 'Road Repair Required',
          description: 'Large pothole causing traffic issues on Main Road near market area',
          category: 'Infrastructure',
          location: 'Main Road, Sector 5',
          priority: 'High',
          status: 'Pending Review',
          reportedBy: 'Citizen Report',
          reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
          deadline: DateTime.now().add(const Duration(days: 2)),
        ),
        Issue(
          id: '2',
          title: 'Street Light Repair',
          description: 'Multiple street lights not functioning in residential area',
          category: 'Electricity',
          location: 'Gandhi Nagar, Block B',
          priority: 'Medium',
          status: 'Pending Review',
          reportedBy: 'Volunteer Verified',
          reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
          deadline: DateTime.now().add(const Duration(days: 5)),
        ),
        Issue(
          id: '3',
          title: 'Water Pipeline Leak',
          description: 'Water leaking from main pipeline causing wastage',
          category: 'Water Supply',
          location: 'Near Primary School',
          priority: 'High',
          status: 'Pending Review',
          reportedBy: 'Citizen Report',
          reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
      ];
      
      final inProgressIssues = [
        Issue(
          id: '4',
          title: 'Drainage Cleaning',
          description: 'Blocked drainage causing waterlogging during rains',
          category: 'Drainage',
          location: 'Market Road',
          priority: 'Medium',
          status: 'In Progress',
          reportedBy: 'Citizen Report',
          reportedAt: DateTime.now().subtract(const Duration(days: 2)),
          assignedTo: 'PWD Team A',
          deadline: DateTime.now().add(const Duration(days: 3)),
        ),
        Issue(
          id: '5',
          title: 'Garbage Collection Setup',
          description: 'Need additional garbage bins in new residential area',
          category: 'Sanitation',
          location: 'New Colony, Phase 2',
          priority: 'Low',
          status: 'In Progress',
          reportedBy: 'SHG Request',
          reportedAt: DateTime.now().subtract(const Duration(days: 3)),
          assignedTo: 'Sanitation Dept',
          deadline: DateTime.now().add(const Duration(days: 7)),
        ),
      ];
      
      emit(OfficerDashboardLoaded(
        stats: stats,
        pendingIssues: pendingIssues,
        inProgressIssues: inProgressIssues,
      ));
    } catch (e) {
      emit(OfficerDashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(RefreshOfficerDashboard event, Emitter<OfficerDashboardState> emit) async {
    if (state is OfficerDashboardLoaded) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state);
    } else {
      add(const LoadOfficerDashboard());
    }
  }

  Future<void> _onUpdateIssueStatus(UpdateIssueStatus event, Emitter<OfficerDashboardState> emit) async {
    // Handle status update - in real app this would call API
    if (state is OfficerDashboardLoaded) {
      final currentState = state as OfficerDashboardLoaded;
      // For demo, just re-emit same state
      emit(OfficerDashboardLoaded(
        stats: currentState.stats,
        pendingIssues: currentState.pendingIssues,
        inProgressIssues: currentState.inProgressIssues,
      ));
    }
  }
}
