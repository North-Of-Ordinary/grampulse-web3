import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LoadProfileCompleteness>(_onLoadProfileCompleteness);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<DeleteProfileImage>(_onDeleteProfileImage);
    on<RefreshProfile>(_onRefreshProfile);
    on<ResetProfileState>(_onResetProfileState);
    on<ShowProfileCompletionPrompt>(_onShowProfileCompletionPrompt);
    on<DismissProfileCompletionPrompt>(_onDismissProfileCompletionPrompt);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    try {
      print('🔄 BLOC: Loading profile...');
      emit(const ProfileLoading());

      final profile = await _profileRepository.getProfile();
      
      if (profile != null) {
        print('✅ BLOC: Profile loaded successfully');
        
        // Also load completeness information
        try {
          final completeness = await _profileRepository.getProfileCompleteness();
          
          emit(ProfileLoaded(
            profile: profile,
            completeness: completeness,
            showCompletionPrompt: !profile.isProfileComplete,
          ));
        } catch (e) {
          print('⚠️ BLOC: Failed to load completeness, but profile loaded: $e');
          emit(ProfileLoaded(profile: profile));
        }
      } else {
        print('❌ BLOC: Profile is null');
        emit(const ProfileError(message: 'Failed to load profile'));
      }
    } catch (e) {
      print('❌ BLOC: Load profile error: $e');
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    try {
      final currentState = state;
      UserProfile? currentProfile;
      
      if (currentState is ProfileLoaded) {
        currentProfile = currentState.profile;
        emit(ProfileUpdating(currentProfile));
      } else {
        emit(const ProfileLoading());
      }

      print('🔄 BLOC: Updating profile...');
      print('📝 BLOC: Update request: ${event.request}');

      final updatedProfile = await _profileRepository.updateProfile(event.request);
      
      if (updatedProfile != null) {
        print('✅ BLOC: Profile updated successfully');
        
        // Load updated completeness information
        try {
          final completeness = await _profileRepository.getProfileCompleteness();
          
          emit(ProfileUpdated(
            profile: updatedProfile,
            completeness: completeness,
          ));
          
          // Transition to loaded state with updated data
          emit(ProfileLoaded(
            profile: updatedProfile,
            completeness: completeness,
            showCompletionPrompt: !updatedProfile.isProfileComplete,
          ));
        } catch (e) {
          print('⚠️ BLOC: Failed to load completeness after update: $e');
          emit(ProfileUpdated(profile: updatedProfile));
          emit(ProfileLoaded(profile: updatedProfile));
        }
      } else {
        print('❌ BLOC: Updated profile is null');
        emit(ProfileError(
          message: 'Failed to update profile',
          profile: currentProfile,
        ));
      }
    } catch (e) {
      print('❌ BLOC: Update profile error: $e');
      emit(ProfileError(
        message: 'Failed to update profile: ${e.toString()}',
        profile: (state is ProfileLoaded) ? (state as ProfileLoaded).profile : null,
      ));
    }
  }

  Future<void> _onLoadProfileCompleteness(LoadProfileCompleteness event, Emitter<ProfileState> emit) async {
    try {
      print('🔄 BLOC: Loading profile completeness...');
      
      final completeness = await _profileRepository.getProfileCompleteness();
      
      if (completeness != null) {
        print('✅ BLOC: Profile completeness loaded successfully');
        print('📊 BLOC: Completion: ${completeness.completionPercentage}%');
        
        final currentState = state;
        if (currentState is ProfileLoaded) {
          emit(currentState.copyWith(completeness: completeness));
        } else {
          emit(ProfileCompletenessLoaded(completeness: completeness));
        }
      } else {
        print('❌ BLOC: Profile completeness is null');
        emit(const ProfileError(message: 'Failed to load profile completeness'));
      }
    } catch (e) {
      print('❌ BLOC: Load profile completeness error: $e');
      emit(ProfileError(message: 'Failed to load profile completeness: ${e.toString()}'));
    }
  }

  Future<void> _onUploadProfileImage(UploadProfileImage event, Emitter<ProfileState> emit) async {
    try {
      final currentState = state;
      UserProfile? currentProfile;
      
      if (currentState is ProfileLoaded) {
        currentProfile = currentState.profile;
        emit(ProfileImageUploading(currentProfile));
      } else {
        emit(const ProfileLoading());
      }

      print('🔄 BLOC: Uploading profile image...');
      print('📸 BLOC: Image file: ${event.imageFile.path}');

      final imageUrl = await _profileRepository.uploadProfileImage(event.imageFile);
      
      if (imageUrl != null && currentProfile != null) {
        print('✅ BLOC: Profile image uploaded successfully');
        print('🖼️ BLOC: Image URL: $imageUrl');
        
        final updatedProfile = currentProfile.copyWith(profileImageUrl: imageUrl);
        
        emit(ProfileImageUploaded(
          profile: updatedProfile,
          imageUrl: imageUrl,
        ));
        
        // Transition back to loaded state
        final currentLoaded = currentState as ProfileLoaded?;
        emit(ProfileLoaded(
          profile: updatedProfile,
          completeness: currentLoaded?.completeness,
          showCompletionPrompt: currentLoaded?.showCompletionPrompt ?? false,
        ));
      } else {
        print('❌ BLOC: Image upload failed');
        emit(ProfileError(
          message: 'Failed to upload profile image',
          profile: currentProfile,
        ));
      }
    } catch (e) {
      print('❌ BLOC: Upload profile image error: $e');
      emit(ProfileError(
        message: 'Failed to upload profile image: ${e.toString()}',
        profile: (state is ProfileLoaded) ? (state as ProfileLoaded).profile : null,
      ));
    }
  }

  Future<void> _onDeleteProfileImage(DeleteProfileImage event, Emitter<ProfileState> emit) async {
    try {
      final currentState = state;
      UserProfile? currentProfile;
      
      if (currentState is ProfileLoaded) {
        currentProfile = currentState.profile;
      } else {
        emit(const ProfileLoading());
        return;
      }

      print('🔄 BLOC: Deleting profile image...');

      final success = await _profileRepository.deleteProfileImage();
      
      if (success && currentProfile != null) {
        print('✅ BLOC: Profile image deleted successfully');
        
        final updatedProfile = currentProfile.copyWith(profileImageUrl: null);
        
        emit(ProfileImageDeleted(updatedProfile));
        
        // Transition back to loaded state
        final currentLoaded = currentState as ProfileLoaded;
        emit(ProfileLoaded(
          profile: updatedProfile,
          completeness: currentLoaded.completeness,
          showCompletionPrompt: currentLoaded.showCompletionPrompt,
        ));
      } else {
        print('❌ BLOC: Image deletion failed');
        emit(ProfileError(
          message: 'Failed to delete profile image',
          profile: currentProfile,
        ));
      }
    } catch (e) {
      print('❌ BLOC: Delete profile image error: $e');
      emit(ProfileError(
        message: 'Failed to delete profile image: ${e.toString()}',
        profile: (state is ProfileLoaded) ? (state as ProfileLoaded).profile : null,
      ));
    }
  }

  Future<void> _onRefreshProfile(RefreshProfile event, Emitter<ProfileState> emit) async {
    print('🔄 BLOC: Refreshing profile data...');
    add(const LoadProfile());
  }

  Future<void> _onResetProfileState(ResetProfileState event, Emitter<ProfileState> emit) async {
    print('🔄 BLOC: Resetting profile state...');
    emit(const ProfileInitial());
  }

  Future<void> _onShowProfileCompletionPrompt(ShowProfileCompletionPrompt event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(showCompletionPrompt: true));
    }
  }

  Future<void> _onDismissProfileCompletionPrompt(DismissProfileCompletionPrompt event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(showCompletionPrompt: false));
    }
  }
}
