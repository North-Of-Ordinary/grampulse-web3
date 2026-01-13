import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'citizen_home_event.dart';
import 'citizen_home_state.dart';

class CitizenHomeBloc extends Bloc<CitizenHomeEvent, CitizenHomeState> {
  final SupabaseService _supabase = SupabaseService();
  
  CitizenHomeBloc() : super(const CitizenHomeInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<CitizenHomeState> emit,
  ) async {
    try {
      emit(const CitizenHomeLoading());
      debugPrint('[CitizenHomeBloc] Loading dashboard...');
      
      // Get user name from SharedPreferences (set during login)
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? 'User';
      final userId = prefs.getString('user_id');
      
      // Get statistics from Supabase
      final statistics = await _getStatistics(userId);
      
      debugPrint('[CitizenHomeBloc] ✅ Loaded - User: $userName');
      emit(CitizenHomeLoaded(
        userName: userName,
        statistics: statistics,
      ));
    } catch (e) {
      debugPrint('[CitizenHomeBloc] ❌ Error: $e');
      // Fallback to basic info on error
      emit(const CitizenHomeLoaded(
        userName: 'User',
        statistics: {},
      ));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<CitizenHomeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is CitizenHomeLoaded) {
        emit(CitizenHomeRefreshing(
          userName: currentState.userName,
          statistics: currentState.statistics,
        ));
      } else {
        emit(const CitizenHomeLoading());
      }
      
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? 'User';
      final userId = prefs.getString('user_id');
      
      final statistics = await _getStatistics(userId);
      
      emit(CitizenHomeLoaded(
        userName: userName,
        statistics: statistics,
      ));
    } catch (e) {
      debugPrint('[CitizenHomeBloc] ❌ Refresh error: $e');
      emit(const CitizenHomeError(message: 'Failed to refresh dashboard'));
    }
  }

  /// Get statistics from Supabase
  Future<Map<String, dynamic>> _getStatistics(String? userId) async {
    try {
      final stats = await _supabase.getIncidentStatistics(reporterId: userId);
      return {
        'totalIssues': stats['total'] ?? 0,
        'newIssues': stats['new'] ?? 0,
        'inProgress': stats['in_progress'] ?? 0,
        'resolved': stats['resolved'] ?? 0,
      };
    } catch (e) {
      debugPrint('[CitizenHomeBloc] ⚠️ Stats error: $e');
      return {};
    }
  }
}
