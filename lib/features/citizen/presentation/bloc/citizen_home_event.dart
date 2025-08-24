part of 'citizen_home_bloc.dart';

abstract class CitizenHomeEvent extends Equatable {
  const CitizenHomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeEvent extends CitizenHomeEvent {}

class RefreshHomeEvent extends CitizenHomeEvent {}

class UpdateLocationEvent extends CitizenHomeEvent {
  final String locationName;

  const UpdateLocationEvent({required this.locationName});

  @override
  List<Object?> get props => [locationName];
}
