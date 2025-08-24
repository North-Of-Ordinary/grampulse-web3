import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/issue_model.dart';

part 'citizen_home_event.dart';
part 'citizen_home_state.dart';

class CitizenHomeBloc extends Bloc<CitizenHomeEvent, CitizenHomeState> {
  CitizenHomeBloc() : super(CitizenHomeInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<SearchIssues>(_onSearchIssues);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event, 
    Emitter<CitizenHomeState> emit,
  ) async {
    try {
      emit(CitizenHomeLoading());
      
      // Here we would fetch data from repositories
      // For now we'll use mock data
      
      // This would be fetched from user repository
      final userName = "John Doe";
      
      // These would be fetched from statistics repository
      final statistics = {
        'totalReported': 12,
        'inProgress': 5,
        'resolved': 7,
      };
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(CitizenHomeLoaded(
        userName: userName,
        statistics: statistics,
      ));
    } catch (error) {
      emit(CitizenHomeError(message: error.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event, 
    Emitter<CitizenHomeState> emit,
  ) async {
    try {
      // Keep existing state data while refreshing
      final currentState = state;
      if (currentState is CitizenHomeLoaded) {
        emit(CitizenHomeRefreshing(
          userName: currentState.userName,
          statistics: currentState.statistics,
        ));
      } else {
        emit(CitizenHomeLoading());
      }
      
      // Re-fetch data from repositories
      await Future.delayed(const Duration(milliseconds: 800));
      
      // This would be fetched from user repository
      final userName = "John Doe";
      
      // These would be fetched from statistics repository
      final statistics = {
        'totalReported': 12,
        'inProgress': 5,
        'resolved': 7,
      };
      
      emit(CitizenHomeLoaded(
        userName: userName,
        statistics: statistics,
      ));
    } catch (error) {
      emit(CitizenHomeError(message: error.toString()));
    }
  }

  Future<void> _onSearchIssues(
    SearchIssues event, 
    Emitter<CitizenHomeState> emit,
  ) async {
    try {
      // Keep existing state but indicate search is happening
      final currentState = state;
      if (currentState is CitizenHomeLoaded) {
        emit(CitizenHomeSearching(
          userName: currentState.userName,
          statistics: currentState.statistics,
          searchQuery: event.query,
        ));
        
        // Perform search (would be in a repository)
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Return to loaded state with search results if needed
        emit(CitizenHomeLoaded(
          userName: currentState.userName,
          statistics: currentState.statistics,
        ));
      }
    } catch (error) {
      emit(CitizenHomeError(message: error.toString()));
    }
  }
}
