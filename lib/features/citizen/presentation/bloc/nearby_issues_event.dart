part of 'nearby_issues_bloc.dart';

abstract class NearbyIssuesEvent extends Equatable {
  const NearbyIssuesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyIssuesEvent extends NearbyIssuesEvent {}

class UpdateLocationRadiusEvent extends NearbyIssuesEvent {
  final double radiusInKm;

  const UpdateLocationRadiusEvent({required this.radiusInKm});

  @override
  List<Object?> get props => [radiusInKm];
}
