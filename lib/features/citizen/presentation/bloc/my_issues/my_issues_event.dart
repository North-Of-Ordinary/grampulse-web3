part of 'my_issues_bloc.dart';

/// Events for My Issues section
abstract class MyIssuesEvent extends Equatable {
  const MyIssuesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user's issues initially
class LoadMyIssues extends MyIssuesEvent {}

/// Event to refresh user's issues
class RefreshMyIssues extends MyIssuesEvent {}

/// Event to filter user's issues
class FilterMyIssues extends MyIssuesEvent {
  final IssueCategory? categoryFilter;
  final IssueStatus? statusFilter;

  const FilterMyIssues({
    this.categoryFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [categoryFilter, statusFilter];
}

/// Event to sort user's issues
class SortMyIssues extends MyIssuesEvent {
  final String sortBy; // date, status, priority
  final bool ascending;

  const SortMyIssues({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}
