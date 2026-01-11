import 'package:equatable/equatable.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:latlong2/latlong.dart';

abstract class NearbyMapEvent extends Equatable {
  const NearbyMapEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadMap extends NearbyMapEvent {
  final LatLng? initialLocation;
  
  const LoadMap({this.initialLocation});
  
  @override
  List<Object?> get props => [initialLocation];
}

class FilterByCategory extends NearbyMapEvent {
  final String? categoryId;
  
  const FilterByCategory(this.categoryId);
  
  @override
  List<Object?> get props => [categoryId];
}

class SelectIssue extends NearbyMapEvent {
  final IssueModel issue;
  
  const SelectIssue(this.issue);
  
  @override
  List<Object> get props => [issue];
}

class ClearSelectedIssue extends NearbyMapEvent {}

class UpdateUserLocation extends NearbyMapEvent {
  final LatLng location;
  
  const UpdateUserLocation(this.location);
  
  @override
  List<Object> get props => [location];
}

class NavigateToIssue extends NearbyMapEvent {
  final IssueModel issue;
  
  const NavigateToIssue(this.issue);
  
  @override
  List<Object> get props => [issue];
}

class ViewIssueDetails extends NearbyMapEvent {
  final IssueModel issue;
  
  const ViewIssueDetails(this.issue);
  
  @override
  List<Object> get props => [issue];
}
