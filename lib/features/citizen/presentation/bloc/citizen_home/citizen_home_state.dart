import 'package:equatable/equatable.dart';

/// States for the Citizen Home screen
abstract class CitizenHomeState extends Equatable {
  const CitizenHomeState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class CitizenHomeInitial extends CitizenHomeState {
  const CitizenHomeInitial();
}

/// Loading state when first fetching data
class CitizenHomeLoading extends CitizenHomeState {
  const CitizenHomeLoading();
}

/// Refreshing state when refreshing data but still displaying old data
class CitizenHomeRefreshing extends CitizenHomeState {
  final String userName;
  final Map<String, dynamic> statistics;

  const CitizenHomeRefreshing({
    required this.userName,
    required this.statistics,
  });
  
  @override
  List<Object?> get props => [userName, statistics];
}

/// Searching state when performing a search
class CitizenHomeSearching extends CitizenHomeState {
  final String userName;
  final Map<String, dynamic> statistics;
  final String searchQuery;

  const CitizenHomeSearching({
    required this.userName,
    required this.statistics,
    required this.searchQuery,
  });
  
  @override
  List<Object?> get props => [userName, statistics, searchQuery];
}

/// Loaded state when data is available
class CitizenHomeLoaded extends CitizenHomeState {
  final String userName;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic>? filters;

  const CitizenHomeLoaded({
    required this.userName,
    required this.statistics,
    this.filters,
  });
  
  @override
  List<Object?> get props => [userName, statistics, filters];
}

/// Error state when something goes wrong
class CitizenHomeError extends CitizenHomeState {
  final String message;

  const CitizenHomeError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
