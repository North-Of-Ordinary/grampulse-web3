import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

part 'nearby_issues_event.dart';
part 'nearby_issues_state.dart';

class NearbyIssuesBloc extends Bloc<NearbyIssuesEvent, NearbyIssuesState> {
  // Repositories would be injected here in real implementation
  // final IssueRepository issueRepository;
  // final LocationRepository locationRepository;

  NearbyIssuesBloc() : super(NearbyIssuesInitial()) {
    on<LoadNearbyIssuesEvent>(_onLoadNearbyIssues);
    on<UpdateLocationRadiusEvent>(_onUpdateLocationRadius);
  }

  FutureOr<void> _onLoadNearbyIssues(
    LoadNearbyIssuesEvent event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    emit(NearbyIssuesLoading());
    
    try {
      // Simulate delay for API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, we would get data from repositories based on current location
      // For now, we'll use a fixed location (Chennai, India)
      final currentLocation = LatLng(13.0827, 80.2707);
      final nearbyIssues = _getMockNearbyIssues();
      
      emit(NearbyIssuesLoaded(
        currentLocation: currentLocation,
        issues: nearbyIssues,
        radiusInKm: 2.0,
      ));
    } catch (e) {
      emit(NearbyIssuesError(message: e.toString()));
    }
  }

  FutureOr<void> _onUpdateLocationRadius(
    UpdateLocationRadiusEvent event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    if (state is NearbyIssuesLoaded) {
      final currentState = state as NearbyIssuesLoaded;
      
      emit(NearbyIssuesLoading());
      
      try {
        // Simulate delay for API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        // In a real app, we would fetch new issues based on the updated radius
        final nearbyIssues = _getMockNearbyIssues();
        
        emit(currentState.copyWith(
          radiusInKm: event.radiusInKm,
          issues: nearbyIssues,
        ));
      } catch (e) {
        emit(NearbyIssuesError(message: e.toString()));
      }
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
        'coordinates': LatLng(13.0837, 80.2717),
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
        'coordinates': LatLng(13.0817, 80.2697),
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
        'coordinates': LatLng(13.0847, 80.2727),
        'distance': '1.2 km',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '4',
        'title': 'Garbage Dump',
        'description': 'Uncollected garbage causing health issues',
        'category': 'Sanitation',
        'categoryIcon': 'sanitation',
        'status': 'new',
        'location': 'Market Area, Main Road',
        'coordinates': LatLng(13.0807, 80.2737),
        'distance': '1.5 km',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': '5',
        'title': 'Fallen Tree',
        'description': 'Tree fallen on road after storm',
        'category': 'Environment',
        'categoryIcon': 'environment',
        'status': 'in_progress',
        'location': 'School Road, Near Temple',
        'coordinates': LatLng(13.0857, 80.2697),
        'distance': '1.8 km',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
  }
}
