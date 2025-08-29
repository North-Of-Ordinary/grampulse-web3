import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/profile_completeness.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded state
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final ProfileCompleteness? completeness;
  final bool showCompletionPrompt;

  const ProfileLoaded({
    required this.profile,
    this.completeness,
    this.showCompletionPrompt = false,
  });

  @override
  List<Object?> get props => [profile, completeness, showCompletionPrompt];

  ProfileLoaded copyWith({
    UserProfile? profile,
    ProfileCompleteness? completeness,
    bool? showCompletionPrompt,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      completeness: completeness ?? this.completeness,
      showCompletionPrompt: showCompletionPrompt ?? this.showCompletionPrompt,
    );
  }
}

/// Profile updating state
class ProfileUpdating extends ProfileState {
  final UserProfile currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

/// Profile updated state
class ProfileUpdated extends ProfileState {
  final UserProfile profile;
  final ProfileCompleteness? completeness;

  const ProfileUpdated({
    required this.profile,
    this.completeness,
  });

  @override
  List<Object?> get props => [profile, completeness];
}

/// Image uploading state
class ProfileImageUploading extends ProfileState {
  final UserProfile currentProfile;

  const ProfileImageUploading(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

/// Image uploaded state
class ProfileImageUploaded extends ProfileState {
  final UserProfile profile;
  final String imageUrl;

  const ProfileImageUploaded({
    required this.profile,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [profile, imageUrl];
}

/// Image deleted state
class ProfileImageDeleted extends ProfileState {
  final UserProfile profile;

  const ProfileImageDeleted(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;
  final UserProfile? profile;

  const ProfileError({
    required this.message,
    this.profile,
  });

  @override
  List<Object?> get props => [message, profile];
}

/// Profile completeness loaded state
class ProfileCompletenessLoaded extends ProfileState {
  final ProfileCompleteness completeness;
  final UserProfile? profile;

  const ProfileCompletenessLoaded({
    required this.completeness,
    this.profile,
  });

  @override
  List<Object?> get props => [completeness, profile];
}
