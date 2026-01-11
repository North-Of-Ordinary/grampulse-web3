part of 'nearby_issues_bloc.dart';

/// States for the Nearby Issues section
abstract class NearbyIssuesState extends Equatable {
  const NearbyIssuesState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class NearbyIssuesInitial extends NearbyIssuesState {}

/// Loading state when first fetching data
class NearbyIssuesLoading extends NearbyIssuesState {}

/// Refreshing state when refreshing data but still displaying old data
class NearbyIssuesRefreshing extends NearbyIssuesState {
  final List<Issue> issues;

  const NearbyIssuesRefreshing({
    required this.issues,
  });
  
  @override
  List<Object?> get props => [issues];
}

/// Loaded state when nearby issues are available
class NearbyIssuesLoaded extends NearbyIssuesState {
  final List<Issue> issues;
  final GeoLocation? location;
  final Map<String, dynamic>? activeFilters;
  final String? selectedIssueId;

  const NearbyIssuesLoaded({
    required this.issues,
    this.location,
    this.activeFilters,
    this.selectedIssueId,
  });
  
  @override
  List<Object?> get props => [issues, location, activeFilters, selectedIssueId];
}

/// Error state when something goes wrong
class NearbyIssuesError extends NearbyIssuesState {
  final String message;

  const NearbyIssuesError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
