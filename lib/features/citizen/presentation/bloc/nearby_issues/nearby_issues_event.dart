part of 'nearby_issues_bloc.dart';

/// Events for the Nearby Issues section
abstract class NearbyIssuesEvent extends Equatable {
  const NearbyIssuesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load nearby issues initially
class LoadNearbyIssues extends NearbyIssuesEvent {}

/// Event to refresh nearby issues
class RefreshNearbyIssues extends NearbyIssuesEvent {}

/// Event to update user's location
class UpdateLocation extends NearbyIssuesEvent {
  final GeoLocation location;

  const UpdateLocation({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Event to filter nearby issues
class FilterNearbyIssues extends NearbyIssuesEvent {
  final IssueCategory? categoryFilter;
  final IssueStatus? statusFilter;
  final double? radiusInKm;

  const FilterNearbyIssues({
    this.categoryFilter,
    this.statusFilter,
    this.radiusInKm,
  });

  @override
  List<Object?> get props => [categoryFilter, statusFilter, radiusInKm];
}

/// Event to select an issue on the map
class SelectIssueOnMap extends NearbyIssuesEvent {
  final String issueId;

  const SelectIssueOnMap(this.issueId);

  @override
  List<Object?> get props => [issueId];
}
