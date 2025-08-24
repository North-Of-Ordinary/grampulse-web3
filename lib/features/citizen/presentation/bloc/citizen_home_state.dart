part of 'citizen_home_bloc.dart';

abstract class CitizenHomeState extends Equatable {
  const CitizenHomeState();
  
  @override
  List<Object?> get props => [];
}

class CitizenHomeInitial extends CitizenHomeState {}

class CitizenHomeLoading extends CitizenHomeState {}

class CitizenHomeLoaded extends CitizenHomeState {
  final File? profileImage;
  final String locationName;
  final List<Map<String, dynamic>> nearbyIssues;
  final List<Map<String, dynamic>> myIssues;
  final bool isRefreshing;

  const CitizenHomeLoaded({
    this.profileImage,
    required this.locationName,
    required this.nearbyIssues,
    required this.myIssues,
    this.isRefreshing = false,
  });

  CitizenHomeLoaded copyWith({
    File? profileImage,
    String? locationName,
    List<Map<String, dynamic>>? nearbyIssues,
    List<Map<String, dynamic>>? myIssues,
    bool? isRefreshing,
  }) {
    return CitizenHomeLoaded(
      profileImage: profileImage ?? this.profileImage,
      locationName: locationName ?? this.locationName,
      nearbyIssues: nearbyIssues ?? this.nearbyIssues,
      myIssues: myIssues ?? this.myIssues,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    profileImage, 
    locationName, 
    nearbyIssues, 
    myIssues,
    isRefreshing,
  ];
}

class CitizenHomeError extends CitizenHomeState {
  final String message;

  const CitizenHomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
