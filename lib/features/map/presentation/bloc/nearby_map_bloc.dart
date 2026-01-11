import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grampulse/features/map/domain/models/category_model.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_event.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class NearbyMapBloc extends Bloc<NearbyMapEvent, NearbyMapState> {
  NearbyMapBloc() : super(MapInitial()) {
    on<LoadMap>(_onLoadMap);
    on<FilterByCategory>(_onFilterByCategory);
    on<SelectIssue>(_onSelectIssue);
    on<ClearSelectedIssue>(_onClearSelectedIssue);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<NavigateToIssue>(_onNavigateToIssue);
    on<ViewIssueDetails>(_onViewIssueDetails);
  }

  Future<void> _onLoadMap(
    LoadMap event,
    Emitter<NearbyMapState> emit,
  ) async {
    emit(MapLoading());
    
    try {
      // Get user location
      LatLng userLocation;
      if (event.initialLocation != null) {
        userLocation = event.initialLocation!;
      } else {
        final position = await _determinePosition();
        userLocation = LatLng(position.latitude, position.longitude);
      }
      
      // Fetch issues from repository (mocked for now)
      final issues = await _fetchMockIssues(userLocation);
      
      emit(MapLoaded(
        issues: issues,
        userLocation: userLocation,
      ));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<NearbyMapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      
      emit(currentState.copyWith(
        selectedCategory: event.categoryId == 'all' ? null : event.categoryId,
      ));
    }
  }

  Future<void> _onSelectIssue(
    SelectIssue event,
    Emitter<NearbyMapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      
      emit(MapSelectingIssue(
        selectedIssue: event.issue,
        issues: currentState.issues,
        userLocation: currentState.userLocation,
        selectedCategory: currentState.selectedCategory,
      ));
    }
  }

  Future<void> _onClearSelectedIssue(
    ClearSelectedIssue event,
    Emitter<NearbyMapState> emit,
  ) async {
    if (state is MapSelectingIssue) {
      final currentState = state as MapSelectingIssue;
      
      emit(MapLoaded(
        issues: currentState.issues,
        userLocation: currentState.userLocation,
        selectedCategory: currentState.selectedCategory,
      ));
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<NearbyMapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      
      emit(currentState.copyWith(
        userLocation: event.location,
      ));
    } else if (state is MapSelectingIssue) {
      final currentState = state as MapSelectingIssue;
      
      emit(MapSelectingIssue(
        selectedIssue: currentState.selectedIssue,
        issues: currentState.issues,
        userLocation: event.location,
        selectedCategory: currentState.selectedCategory,
      ));
    }
  }

  void _onNavigateToIssue(NavigateToIssue event, Emitter<NearbyMapState> emit) {
    // This would integrate with a maps application
    // Implementation depends on platform and requirements
    print('Navigating to issue: ${event.issue.id} at ${event.issue.latitude}, ${event.issue.longitude}');
  }

  void _onViewIssueDetails(ViewIssueDetails event, Emitter<NearbyMapState> emit) {
    // This would navigate to the issue details screen
    // Implementation depends on navigation setup
    print('Viewing details for issue: ${event.issue.id}');
  }

  // Helper function to get user's current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Mock data for development
  Future<List<IssueModel>> _fetchMockIssues(LatLng userLocation) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Generate mock categories
    final categories = _getMockCategories();
    
    // Generate mock issues around the user location
    final issues = <IssueModel>[];
    
    // Create 15 mock issues with varying distances from user location
    for (int i = 0; i < 15; i++) {
      // Randomize location a bit around the user
      final latOffset = (i % 5 - 2) * 0.002;
      final lngOffset = (i ~/ 3 - 1) * 0.003;
      
      // Alternate between categories
      final category = categories[i % categories.length];
      
      // Alternate between statuses
      final statuses = ['new', 'in_progress', 'resolved', 'rejected'];
      final status = statuses[i % statuses.length];
      
      // Create the issue
      issues.add(IssueModel(
        id: 'issue_$i',
        title: 'Issue ${i + 1}: ${category.name} Problem',
        description: 'This is a mock ${category.name} issue for testing the map view.',
        category: category,
        status: status,
        createdAt: DateTime.now().subtract(Duration(days: i, hours: i * 2)),
        latitude: userLocation.latitude + latOffset,
        longitude: userLocation.longitude + lngOffset,
        address: 'Mock Address ${i + 1}, Test City',
        media: i % 3 == 0 ? _getMockMedia() : [],
        severity: 1 + (i % 3),
        reporterId: 'user_${100 + i}',
      ));
    }
    
    return issues;
  }

  List<CategoryModel> _getMockCategories() {
    return [
      CategoryModel(
        id: 'roads',
        name: 'Roads',
        iconCode: '0xe3e7', // directions_car
        color: Colors.brown,
      ),
      CategoryModel(
        id: 'water',
        name: 'Water',
        iconCode: '0xe798', // water_drop
        color: Colors.blue,
      ),
      CategoryModel(
        id: 'power',
        name: 'Power',
        iconCode: '0xe63c', // power
        color: Colors.amber,
      ),
      CategoryModel(
        id: 'sanitation',
        name: 'Sanitation',
        iconCode: '0xe308', // cleaning_services
        color: Colors.green,
      ),
      CategoryModel(
        id: 'safety',
        name: 'Safety',
        iconCode: '0xe3ae', // health_and_safety
        color: Colors.red,
      ),
      CategoryModel(
        id: 'others',
        name: 'Others',
        iconCode: '0xe8b6', // more_horiz
        color: Colors.purple,
      ),
    ];
  }

  List<MediaModel> _getMockMedia() {
    // In a real app, these would be actual image URLs or paths
    return [
      MediaModel(
        id: 'media_1',
        url: 'https://via.placeholder.com/800x600.png',
        thumbnailUrl: 'https://via.placeholder.com/150x150.png',
        type: MediaType.image,
      ),
      MediaModel(
        id: 'media_2',
        url: 'https://via.placeholder.com/800x600.png?text=Issue+Photo+2',
        thumbnailUrl: 'https://via.placeholder.com/150x150.png?text=Thumb+2',
        type: MediaType.image,
      ),
    ];
  }
}
