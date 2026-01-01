import 'package:equatable/equatable.dart';

/// Events for the Citizen Home screen
abstract class CitizenHomeEvent extends Equatable {
  const CitizenHomeEvent();

  @override
  List<Object> get props => [];
}

/// Event to load dashboard data initially
class LoadDashboard extends CitizenHomeEvent {
  const LoadDashboard();
}

/// Event to refresh dashboard data
class RefreshDashboard extends CitizenHomeEvent {
  const RefreshDashboard();
}

/// Event to search for issues
class SearchIssues extends CitizenHomeEvent {
  final String query;

  const SearchIssues(this.query);

  @override
  List<Object> get props => [query];
}

/// Event to navigate to specific tab
class NavigateToTab extends CitizenHomeEvent {
  final int index;

  const NavigateToTab(this.index);

  @override
  List<Object> get props => [index];
}

/// Event to open filter dialog
class OpenFilter extends CitizenHomeEvent {}

/// Event to apply filters
class ApplyFilters extends CitizenHomeEvent {
  final Map<String, dynamic> filters;

  const ApplyFilters(this.filters);

  @override
  List<Object> get props => [filters];
}

/// Event to clear applied filters
class ClearFilters extends CitizenHomeEvent {}
