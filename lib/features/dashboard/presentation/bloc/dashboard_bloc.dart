/// Dashboard BLoC - State Management for Transparency Dashboard

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/web3/dashboard_service.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class LoadCategoryStats extends DashboardEvent {}

class LoadPanchayatRankings extends DashboardEvent {}

class LoadDailyTrend extends DashboardEvent {
  final int days;
  const LoadDailyTrend({this.days = 30});

  @override
  List<Object?> get props => [days];
}

class LoadRecentAttestations extends DashboardEvent {
  final int limit;
  const LoadRecentAttestations({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final AggregateStats stats;
  final List<RecentAttestation>? recentAttestations;

  const DashboardLoaded({
    required this.stats,
    this.recentAttestations,
  });

  @override
  List<Object?> get props => [stats, recentAttestations];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;

  DashboardBloc({DashboardService? dashboardService})
      : _dashboardService = dashboardService ?? DashboardService(),
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadRecentAttestations>(_onLoadRecentAttestations);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final stats = await _dashboardService.getAggregateStats();
      final recent = await _dashboardService.getRecentAttestations(limit: 5);

      emit(DashboardLoaded(
        stats: stats,
        recentAttestations: recent,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;

    try {
      final stats = await _dashboardService.getAggregateStats();
      final recent = await _dashboardService.getRecentAttestations(limit: 5);

      emit(DashboardLoaded(
        stats: stats,
        recentAttestations: recent,
      ));
    } catch (e) {
      // Restore previous state on error
      if (currentState is DashboardLoaded) {
        emit(currentState);
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onLoadRecentAttestations(
    LoadRecentAttestations event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        final recent = await _dashboardService.getRecentAttestations(
          limit: event.limit,
        );
        emit(DashboardLoaded(
          stats: currentState.stats,
          recentAttestations: recent,
        ));
      } catch (e) {
        // Keep current state on partial failure
        emit(currentState);
      }
    }
  }

  @override
  Future<void> close() {
    _dashboardService.dispose();
    return super.close();
  }
}
