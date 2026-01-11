part of 'my_issues_bloc.dart';

/// States for My Issues section
abstract class MyIssuesState extends Equatable {
  const MyIssuesState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class MyIssuesInitial extends MyIssuesState {}

/// Loading state when first fetching data
class MyIssuesLoading extends MyIssuesState {}

/// Refreshing state when refreshing data but still displaying old data
class MyIssuesRefreshing extends MyIssuesState {
  final List<Issue> reportedIssues;
  final List<Issue> upvotedIssues;

  const MyIssuesRefreshing({
    required this.reportedIssues,
    required this.upvotedIssues,
  });
  
  @override
  List<Object?> get props => [reportedIssues, upvotedIssues];
}

/// Loaded state when user's issues are available
class MyIssuesLoaded extends MyIssuesState {
  final List<Issue> reportedIssues;
  final List<Issue> upvotedIssues;
  final Map<String, dynamic>? activeFilters;
  final String? sortBy;
  final bool? sortAscending;
  
  const MyIssuesLoaded({
    required this.reportedIssues,
    required this.upvotedIssues,
    this.activeFilters,
    this.sortBy,
    this.sortAscending,
  });
  
  @override
  List<Object?> get props => [
    reportedIssues, 
    upvotedIssues, 
    activeFilters,
    sortBy,
    sortAscending,
  ];
}

/// Error state when something goes wrong
class MyIssuesError extends MyIssuesState {
  final String message;

  const MyIssuesError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
