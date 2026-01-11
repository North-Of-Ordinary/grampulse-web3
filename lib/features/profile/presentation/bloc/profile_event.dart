import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/models/profile_update_request.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user profile
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Event to update user profile
class UpdateProfile extends ProfileEvent {
  final ProfileUpdateRequest request;

  const UpdateProfile(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to load profile completeness
class LoadProfileCompleteness extends ProfileEvent {
  const LoadProfileCompleteness();
}

/// Event to upload profile image
class UploadProfileImage extends ProfileEvent {
  final File imageFile;

  const UploadProfileImage(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

/// Event to delete profile image
class DeleteProfileImage extends ProfileEvent {
  const DeleteProfileImage();
}

/// Event to refresh profile data
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

/// Event to reset profile state
class ResetProfileState extends ProfileEvent {
  const ResetProfileState();
}

/// Event to show profile completion prompt
class ShowProfileCompletionPrompt extends ProfileEvent {
  const ShowProfileCompletionPrompt();
}

/// Event to dismiss profile completion prompt
class DismissProfileCompletionPrompt extends ProfileEvent {
  const DismissProfileCompletionPrompt();
}
