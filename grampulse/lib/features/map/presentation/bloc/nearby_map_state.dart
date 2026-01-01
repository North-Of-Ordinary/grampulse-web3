import 'package:equatable/equatable.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:latlong2/latlong.dart';

abstract class NearbyMapState extends Equatable {
  const NearbyMapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends NearbyMapState {}

class MapLoading extends NearbyMapState {}

class MapLoaded extends NearbyMapState {
  final List<IssueModel> issues;
  final LatLng userLocation;
  final String? selectedCategory;
  
  const MapLoaded({
    required this.issues,
    required this.userLocation,
    this.selectedCategory,
  });
  
  @override
  List<Object?> get props => [issues, userLocation, selectedCategory];
  
  MapLoaded copyWith({
    List<IssueModel>? issues,
    LatLng? userLocation,
    String? selectedCategory,
  }) {
    return MapLoaded(
      issues: issues ?? this.issues,
      userLocation: userLocation ?? this.userLocation,
      selectedCategory: selectedCategory,
    );
  }
}

class MapSelectingIssue extends NearbyMapState {
  final IssueModel selectedIssue;
  final List<IssueModel> issues;
  final LatLng userLocation;
  final String? selectedCategory;
  
  const MapSelectingIssue({
    required this.selectedIssue,
    required this.issues,
    required this.userLocation,
    this.selectedCategory,
  });
  
  @override
  List<Object?> get props => [selectedIssue, issues, userLocation, selectedCategory];
}

class MapError extends NearbyMapState {
  final String message;
  
  const MapError(this.message);
  
  @override
  List<Object> get props => [message];
}
