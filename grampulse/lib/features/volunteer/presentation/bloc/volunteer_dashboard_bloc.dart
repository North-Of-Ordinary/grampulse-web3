import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class VolunteerDashboardEvent extends Equatable {
  const VolunteerDashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboard extends VolunteerDashboardEvent {
  const LoadDashboard();
}

class RefreshDashboard extends VolunteerDashboardEvent {
  const RefreshDashboard();
}

class AcceptVerification extends VolunteerDashboardEvent {
  final String verificationId;
  
  const AcceptVerification(this.verificationId);
  
  @override
  List<Object> get props => [verificationId];
}

class SkipVerification extends VolunteerDashboardEvent {
  final String verificationId;
  
  const SkipVerification(this.verificationId);
  
  @override
  List<Object> get props => [verificationId];
}

// States
abstract class VolunteerDashboardState extends Equatable {
  const VolunteerDashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends VolunteerDashboardState {
  const DashboardInitial();
}

class DashboardLoading extends VolunteerDashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends VolunteerDashboardState {
  final VolunteerStats stats;
  final List<VerificationRequest> verificationQueue;
  final List<VerificationRequest> nearbyRequests;
  
  const DashboardLoaded({
    required this.stats,
    required this.verificationQueue,
    required this.nearbyRequests,
  });
  
  @override
  List<Object> get props => [stats, verificationQueue, nearbyRequests];
}

class DashboardError extends VolunteerDashboardState {
  final String message;
  
  const DashboardError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Data Models
class VolunteerStats {
  final int pendingVerifications;
  final int verifiedToday;
  final double responseRate;
  final int reputation;
  
  const VolunteerStats({
    required this.pendingVerifications,
    required this.verifiedToday,
    required this.responseRate,
    required this.reputation,
  });
}

class VerificationRequest {
  final String id;
  final String title;
  final String category;
  final String address;
  final double distance;
  final String priority;
  final DateTime reportedAt;
  final String? imageUrl;
  
  const VerificationRequest({
    required this.id,
    required this.title,
    required this.category,
    required this.address,
    required this.distance,
    required this.priority,
    required this.reportedAt,
    this.imageUrl,
  });
}

// BLoC
class VolunteerDashboardBloc extends Bloc<VolunteerDashboardEvent, VolunteerDashboardState> {
  VolunteerDashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<AcceptVerification>(_onAcceptVerification);
    on<SkipVerification>(_onSkipVerification);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<VolunteerDashboardState> emit) async {
    emit(const DashboardLoading());
    
    try {
      // Simulate API calls
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data
      const stats = VolunteerStats(
        pendingVerifications: 12,
        verifiedToday: 5,
        responseRate: 87.5,
        reputation: 245,
      );
      
      final verificationQueue = [
        VerificationRequest(
          id: '1',
          title: 'Broken Street Light',
          category: 'Infrastructure',
          address: '123 Main St, Village Center',
          distance: 0.8,
          priority: 'High',
          reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        VerificationRequest(
          id: '2',
          title: 'Pothole on Road',
          category: 'Road',
          address: '456 Market Road',
          distance: 1.2,
          priority: 'Medium',
          reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        VerificationRequest(
          id: '3',
          title: 'Garbage Collection Issue',
          category: 'Sanitation',
          address: '789 Village Square',
          distance: 2.1,
          priority: 'Low',
          reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];
      
      final nearbyRequests = [
        VerificationRequest(
          id: '4',
          title: 'Water Supply Problem',
          category: 'Water',
          address: '321 Community Center',
          distance: 0.5,
          priority: 'High',
          reportedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        VerificationRequest(
          id: '5',
          title: 'School Roof Leak',
          category: 'Education',
          address: 'Primary School, Sector 2',
          distance: 1.5,
          priority: 'Medium',
          reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
      
      emit(DashboardLoaded(
        stats: stats,
        verificationQueue: verificationQueue,
        nearbyRequests: nearbyRequests,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<VolunteerDashboardState> emit) async {
    // Keep current data while refreshing
    final currentState = state;
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Re-emit with updated data (in real app, fetch fresh data)
      if (currentState is DashboardLoaded) {
        emit(DashboardLoaded(
          stats: currentState.stats,
          verificationQueue: currentState.verificationQueue,
          nearbyRequests: currentState.nearbyRequests,
        ));
      } else {
        add(const LoadDashboard());
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onAcceptVerification(AcceptVerification event, Emitter<VolunteerDashboardState> emit) async {
    // Handle accepting a verification request
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final updatedQueue = currentState.verificationQueue
          .where((r) => r.id != event.verificationId)
          .toList();
      
      emit(DashboardLoaded(
        stats: VolunteerStats(
          pendingVerifications: currentState.stats.pendingVerifications - 1,
          verifiedToday: currentState.stats.verifiedToday + 1,
          responseRate: currentState.stats.responseRate,
          reputation: currentState.stats.reputation + 5,
        ),
        verificationQueue: updatedQueue,
        nearbyRequests: currentState.nearbyRequests,
      ));
    }
  }

  Future<void> _onSkipVerification(SkipVerification event, Emitter<VolunteerDashboardState> emit) async {
    // Handle skipping a verification request
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final updatedQueue = currentState.verificationQueue
          .where((r) => r.id != event.verificationId)
          .toList();
      
      emit(DashboardLoaded(
        stats: currentState.stats,
        verificationQueue: updatedQueue,
        nearbyRequests: currentState.nearbyRequests,
      ));
    }
  }
}
