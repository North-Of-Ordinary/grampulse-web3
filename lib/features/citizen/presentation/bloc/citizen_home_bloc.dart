import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';

part 'citizen_home_event.dart';
part 'citizen_home_state.dart';

class CitizenHomeBloc extends Bloc<CitizenHomeEvent, CitizenHomeState> {
  // Repositories would be injected here in real implementation
  // final UserRepository userRepository;
  // final IssueRepository issueRepository;
  // final LocationRepository locationRepository;

  CitizenHomeBloc() : super(CitizenHomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<RefreshHomeEvent>(_onRefreshHome);
    on<UpdateLocationEvent>(_onUpdateLocation);
  }

  FutureOr<void> _onLoadHome(
    LoadHomeEvent event,
    Emitter<CitizenHomeState> emit,
  ) async {
    emit(CitizenHomeLoading());
    
    try {
      // Simulate delay for API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, we would get data from repositories
      final profileImage = null; // This would be fetched from UserRepository
      final locationName = 'Thiruvallur, Tamil Nadu';
      final nearbyIssues = _getMockNearbyIssues();
      final myIssues = _getMockMyIssues();
      
      emit(CitizenHomeLoaded(
        profileImage: profileImage,
        locationName: locationName,
        nearbyIssues: nearbyIssues,
        myIssues: myIssues,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(CitizenHomeError(message: e.toString()));
    }
  }

  FutureOr<void> _onRefreshHome(
    RefreshHomeEvent event,
    Emitter<CitizenHomeState> emit,
  ) async {
    if (state is CitizenHomeLoaded) {
      final currentState = state as CitizenHomeLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      
      try {
        // Simulate delay for API call
        await Future.delayed(const Duration(seconds: 1));
        
        // In a real app, we would get fresh data from repositories
        final nearbyIssues = _getMockNearbyIssues();
        final myIssues = _getMockMyIssues();
        
        emit(currentState.copyWith(
          nearbyIssues: nearbyIssues,
          myIssues: myIssues,
          isRefreshing: false,
        ));
      } catch (e) {
        emit(CitizenHomeError(message: e.toString()));
      }
    }
  }

  FutureOr<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<CitizenHomeState> emit,
  ) async {
    if (state is CitizenHomeLoaded) {
      final currentState = state as CitizenHomeLoaded;
      emit(currentState.copyWith(locationName: event.locationName));
    }
  }

  // Mock data for development
  List<Map<String, dynamic>> _getMockNearbyIssues() {
    return [
      {
        'id': '1',
        'title': 'Damaged Road',
        'description': 'Deep potholes causing traffic issues',
        'category': 'Roads',
        'categoryIcon': 'road',
        'status': 'new',
        'location': 'Nehru Street, Near Bus Stand',
        'distance': '0.5 km',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '2',
        'title': 'Water Leakage',
        'description': 'Main water pipe leaking for past 3 days',
        'category': 'Water',
        'categoryIcon': 'water',
        'status': 'in_progress',
        'location': 'Gandhi Road, Near Post Office',
        'distance': '0.8 km',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '3',
        'title': 'Street Light Not Working',
        'description': 'Street lights not working in entire colony',
        'category': 'Power',
        'categoryIcon': 'power',
        'status': 'new',
        'location': 'Ambedkar Colony, 3rd Cross',
        'distance': '1.2 km',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockMyIssues() {
    return [
      {
        'id': '101',
        'title': 'Garbage Not Collected',
        'description': 'Garbage not collected for a week',
        'category': 'Sanitation',
        'categoryIcon': 'sanitation',
        'status': 'in_progress',
        'location': 'My Home Area',
        'createdAt': DateTime.now().subtract(const Duration(days: 7)),
      },
      {
        'id': '102',
        'title': 'Damaged Park Bench',
        'description': 'Bench in community park is broken',
        'category': 'Public Property',
        'categoryIcon': 'property',
        'status': 'resolved',
        'location': 'Community Park',
        'createdAt': DateTime.now().subtract(const Duration(days: 14)),
      },
    ];
  }
}
