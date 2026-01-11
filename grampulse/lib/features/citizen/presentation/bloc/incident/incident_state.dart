import 'package:equatable/equatable.dart';
import 'package:grampulse/features/citizen/domain/models/incident_models.dart';

abstract class IncidentState extends Equatable {
  const IncidentState();

  @override
  List<Object?> get props => [];
}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

class IncidentLoaded extends IncidentState {
  final List<IncidentCategory> categories;
  final List<Incident> myIncidents;
  final List<Incident> nearbyIncidents;
  final IncidentStatistics? statistics;

  const IncidentLoaded({
    this.categories = const [],
    this.myIncidents = const [],
    this.nearbyIncidents = const [],
    this.statistics,
  });

  @override
  List<Object?> get props => [categories, myIncidents, nearbyIncidents, statistics];

  IncidentLoaded copyWith({
    List<IncidentCategory>? categories,
    List<Incident>? myIncidents,
    List<Incident>? nearbyIncidents,
    IncidentStatistics? statistics,
  }) {
    return IncidentLoaded(
      categories: categories ?? this.categories,
      myIncidents: myIncidents ?? this.myIncidents,
      nearbyIncidents: nearbyIncidents ?? this.nearbyIncidents,
      statistics: statistics ?? this.statistics,
    );
  }
}

class IncidentError extends IncidentState {
  final String message;

  const IncidentError(this.message);

  @override
  List<Object?> get props => [message];
}

class IncidentCreating extends IncidentState {}

class IncidentCreated extends IncidentState {
  final Incident incident;

  const IncidentCreated(this.incident);

  @override
  List<Object?> get props => [incident];
}
