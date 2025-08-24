part of 'nearby_issues_bloc.dart';

abstract class NearbyIssuesState extends Equatable {
  const NearbyIssuesState();
  
  @override
  List<Object?> get props => [];
}

class NearbyIssuesInitial extends NearbyIssuesState {}

class NearbyIssuesLoading extends NearbyIssuesState {}

class NearbyIssuesLoaded extends NearbyIssuesState {
  final LatLng currentLocation;
  final List<Map<String, dynamic>> issues;
  final double radiusInKm;

  const NearbyIssuesLoaded({
    required this.currentLocation,
    required this.issues,
    required this.radiusInKm,
  });

  NearbyIssuesLoaded copyWith({
    LatLng? currentLocation,
    List<Map<String, dynamic>>? issues,
    double? radiusInKm,
  }) {
    return NearbyIssuesLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      issues: issues ?? this.issues,
      radiusInKm: radiusInKm ?? this.radiusInKm,
    );
  }

  @override
  List<Object?> get props => [currentLocation, issues, radiusInKm];
}

class NearbyIssuesError extends NearbyIssuesState {
  final String message;

  const NearbyIssuesError({required this.message});

  @override
  List<Object?> get props => [message];
}
