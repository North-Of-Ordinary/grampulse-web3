import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:grampulse/features/map/domain/models/category_model.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_event.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class NearbyMapBloc extends Bloc<NearbyMapEvent, NearbyMapState> {
  final SupabaseService _supabase = SupabaseService();
  
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
      
      // Fetch issues from Supabase
      debugPrint('[NearbyMapBloc] Loading issues from Supabase...');
      final issues = await _fetchIssuesFromSupabase();
      debugPrint('[NearbyMapBloc] ✅ Loaded ${issues.length} issues');
      
      emit(MapLoaded(
        issues: issues,
        userLocation: userLocation,
      ));
    } catch (e) {
      debugPrint('[NearbyMapBloc] ❌ Error: $e');
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

  /// Fetch real issues from Supabase
  Future<List<IssueModel>> _fetchIssuesFromSupabase() async {
    final incidentsData = await _supabase.getAllIncidents();
    final categoriesData = await _supabase.getCategories();
    
    // Build category map for quick lookup
    final categoryMap = <String, CategoryModel>{};
    for (final cat in categoriesData) {
      final catId = cat['id'] as String;
      categoryMap[catId] = CategoryModel(
        id: catId,
        name: cat['name'] as String? ?? 'Other',
        iconCode: cat['icon'] as String? ?? '0xe8b6',
        color: _getCategoryColor(cat['name'] as String? ?? 'Other'),
      );
    }
    
    return incidentsData.map((data) {
      final categoryId = data['category_id'] as String? ?? '';
      final category = categoryMap[categoryId] ?? CategoryModel(
        id: 'other',
        name: 'Other',
        iconCode: '0xe8b6',
        color: Colors.purple,
      );
      
      return IssueModel(
        id: data['id'] as String? ?? '',
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        category: category,
        status: data['status'] as String? ?? 'submitted',
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
        latitude: (data['location_lat'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['location_lng'] as num?)?.toDouble() ?? 0.0,
        address: data['location_address'] as String? ?? '',
        media: [],
        severity: data['priority'] == 'high' ? 3 : (data['priority'] == 'medium' ? 2 : 1),
        reporterId: data['user_id'] as String? ?? '',
      );
    }).toList();
  }
  
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'roads': return Colors.brown;
      case 'water supply': return Colors.blue;
      case 'electricity': return Colors.amber;
      case 'sanitation': return Colors.green;
      case 'public safety': return Colors.red;
      case 'health': return Colors.pink;
      case 'education': return Colors.indigo;
      case 'agriculture': return Colors.lightGreen;
      default: return Colors.purple;
    }
  }
}
