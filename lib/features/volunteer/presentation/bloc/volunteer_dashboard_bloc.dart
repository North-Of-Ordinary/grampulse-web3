import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/supabase_service.dart';

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
  final SupabaseService _supabase = SupabaseService();
  
  VolunteerDashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<AcceptVerification>(_onAcceptVerification);
    on<SkipVerification>(_onSkipVerification);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<VolunteerDashboardState> emit) async {
    emit(const DashboardLoading());
    
    try {
      debugPrint('[VolunteerDashboardBloc] Loading from Supabase...');
      
      // Fetch real incidents from Supabase
      final incidents = await _supabase.getAllIncidents();
      final pendingIncidents = incidents.where((inc) => inc['status'] == 'submitted').toList();
      
      // Calculate stats from real data
      final stats = VolunteerStats(
        pendingVerifications: pendingIncidents.length,
        verifiedToday: incidents.where((inc) => inc['status'] == 'in_progress').length,
        responseRate: 0.0, // TODO: Calculate from real data
        reputation: 0, // TODO: Get from user profile
      );
      
      // Convert incidents to verification requests
      final verificationQueue = pendingIncidents.take(5).map((inc) {
        return VerificationRequest(
          id: inc['id'] as String? ?? '',
          title: inc['title'] as String? ?? '',
          category: (inc['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
          address: inc['location_address'] as String? ?? 'Unknown',
          distance: 0.0, // TODO: Calculate from user location
          priority: inc['priority'] as String? ?? 'medium',
          reportedAt: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
      
      // Get nearby requests (all pending for now)
      final nearbyRequests = pendingIncidents.skip(5).take(5).map((inc) {
        return VerificationRequest(
          id: inc['id'] as String? ?? '',
          title: inc['title'] as String? ?? '',
          category: (inc['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
          address: inc['location_address'] as String? ?? 'Unknown',
          distance: 0.0,
          priority: inc['priority'] as String? ?? 'medium',
          reportedAt: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
      
      debugPrint('[VolunteerDashboardBloc] ✅ Loaded ${verificationQueue.length} verification requests');
      
      emit(DashboardLoaded(
        stats: stats,
        verificationQueue: verificationQueue,
        nearbyRequests: nearbyRequests,
      ));
    } catch (e) {
      debugPrint('[VolunteerDashboardBloc] ❌ Error: $e');
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<VolunteerDashboardState> emit) async {
    // Keep current data while refreshing
    final currentState = state;
    
    try {
      // Re-fetch from Supabase
      add(const LoadDashboard());
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
