import 'package:equatable/equatable.dart';
import 'package:grampulse/features/citizen/domain/models/incident_models.dart';

abstract class IncidentEvent extends Equatable {
  const IncidentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends IncidentEvent {}

class LoadMyIncidents extends IncidentEvent {}

class LoadNearbyIncidents extends IncidentEvent {
  final double? latitude;  // Made optional for showing all incidents
  final double? longitude; // Made optional for showing all incidents
  final double radius;

  const LoadNearbyIncidents({
    this.latitude,    // No longer required
    this.longitude,   // No longer required
    this.radius = 5000,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

class LoadStatistics extends IncidentEvent {}

class CreateIncident extends IncidentEvent {
  final String title;
  final String description;
  final String categoryId;
  final double latitude;
  final double longitude;
  final String? address;
  final int severity;
  final bool isAnonymous;

  const CreateIncident({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.latitude,
    required this.longitude,
    this.address,
    this.severity = 1,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        categoryId,
        latitude,
        longitude,
        address,
        severity,
        isAnonymous,
      ];
}

class RefreshIncidents extends IncidentEvent {}
