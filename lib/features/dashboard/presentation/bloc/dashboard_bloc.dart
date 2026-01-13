/// Dashboard BLoC - State Management for Transparency Dashboard (Uses Supabase)

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/supabase_service.dart';
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
  final SupabaseService _supabase = SupabaseService();

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
    
    debugPrint('[DashboardBloc] Loading dashboard from Supabase...');

    try {
      // Get real stats from Supabase
      final stats = await _getStatsFromSupabase();
      final recent = await _getRecentFromSupabase();

      debugPrint('[DashboardBloc] ✅ Loaded real data from Supabase');
      emit(DashboardLoaded(
        stats: stats,
        recentAttestations: recent,
      ));
    } catch (e, stack) {
      debugPrint('[DashboardBloc] ❌ Error: $e');
      debugPrint('[DashboardBloc] Stack: $stack');
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }

  /// Get real statistics from Supabase
  Future<AggregateStats> _getStatsFromSupabase() async {
    final incidentStats = await _supabase.getIncidentStatistics();
    final categories = await _supabase.getCategories();
    final incidents = await _supabase.getAllIncidents();
    
    // Calculate category stats
    final categoryCount = <String, int>{};
    for (final incident in incidents) {
      final catName = (incident['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other';
      categoryCount[catName] = (categoryCount[catName] ?? 0) + 1;
    }
    
    final totalIncidents = incidents.length;
    final topCategories = categoryCount.entries
        .map((e) => CategoryStats(
              name: e.key,
              count: e.value,
              percentage: totalIncidents > 0 ? (e.value / totalIncidents * 100) : 0,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return AggregateStats(
      overview: DashboardOverview(
        totalAttestations: totalIncidents,
        totalResolutions: incidentStats['resolved'] ?? 0,
        averageResolutionTimeHours: 24.0, // TODO: Calculate from real data
        categoriesTracked: categories.length,
        panchayatsActive: 1, // TODO: Calculate from real data
        lastUpdated: DateTime.now(),
        network: NetworkInfo(
          name: 'Shardeum EVM Testnet',
          chainId: 8119,
          easContract: '0x4200...0021',
        ),
      ),
      topCategories: topCategories.take(5).toList(),
      topPanchayats: [], // TODO: Implement panchayat rankings
      weeklyTrend: _calculateWeeklyTrend(incidents),
      generatedAt: DateTime.now(),
    );
  }

  /// Calculate weekly trend from real incidents
  TrendData _calculateWeeklyTrend(List<Map<String, dynamic>> incidents) {
    final now = DateTime.now();
    final points = <TrendPoint>[];
    
    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final count = incidents.where((inc) {
        final created = DateTime.tryParse(inc['created_at'] as String? ?? '');
        if (created == null) return false;
        return created.isAfter(dayStart) && created.isBefore(dayEnd);
      }).length;
      
      points.add(TrendPoint(date: dayStart, count: count));
    }
    
    final total = points.fold<int>(0, (sum, p) => sum + p.count);
    return TrendData(
      points: points,
      total: total,
      average: points.isNotEmpty ? total / points.length : 0,
    );
  }

  /// Get recent incidents as attestations from Supabase
  Future<List<RecentAttestation>> _getRecentFromSupabase() async {
    final incidents = await _supabase.getIncidents(limit: 5);
    
    return incidents.map((inc) => RecentAttestation(
      uid: inc['id'] as String? ?? '',
      category: (inc['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
      panchayatId: 'GRAM-001',
      resolutionTimeHours: 24.0,
      timestamp: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
      officerHash: inc['assigned_officer_id'] as String? ?? 'Pending',
    )).toList();
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;
    debugPrint('[DashboardBloc] Refreshing dashboard from Supabase...');

    try {
      final stats = await _getStatsFromSupabase();
      final recent = await _getRecentFromSupabase();

      debugPrint('[DashboardBloc] ✅ Refreshed from Supabase');
      emit(DashboardLoaded(
        stats: stats,
        recentAttestations: recent,
      ));
    } catch (e) {
      debugPrint('[DashboardBloc] ❌ Refresh error: $e');
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
        final incidents = await _supabase.getIncidents(limit: event.limit);
        final recent = incidents.map((inc) => RecentAttestation(
          uid: inc['id'] as String? ?? '',
          category: (inc['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
          panchayatId: 'GRAM-001',
          resolutionTimeHours: 24.0,
          timestamp: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
          officerHash: inc['assigned_officer_id'] as String? ?? 'Pending',
        )).toList();
        
        emit(DashboardLoaded(
          stats: currentState.stats,
          recentAttestations: recent,
        ));
      } catch (e) {
        // Keep current state on partial failure
        debugPrint('[DashboardBloc] ❌ Load attestations error: $e');
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
