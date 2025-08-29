import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../data/repositories/profile_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_completeness_card.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_actions_section.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        ProfileRepository(ApiService()),
      )..add(const LoadProfile()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: state is ProfileLoaded
                    ? () => _navigateToEditProfile(context, state.profile)
                    : null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProfileBloc>().add(const RefreshProfile());
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ProfileBloc>().add(const LoadProfile());
                  },
                ),
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileImageUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileImageDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileError && state.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfile());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show content for states that have profile data
          final profile = _getProfileFromState(state);
          final completeness = _getCompletenessFromState(state);
          final isUpdating = state is ProfileUpdating || state is ProfileImageUploading;

          if (profile == null) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const RefreshProfile());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header with Image and Basic Info
                  ProfileHeader(
                    profile: profile,
                    isUpdating: isUpdating,
                    onImageTap: () => _handleImageTap(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Profile Completeness Card
                  if (completeness != null)
                    ProfileCompletenessCard(
                      completeness: completeness,
                      onCompleteProfile: () => _navigateToEditProfile(context, profile),
                    ),
                  
                  if (completeness != null) const SizedBox(height: 24),
                  
                  // Profile Information Sections
                  ProfileInfoSection(profile: profile),
                  
                  const SizedBox(height: 24),
                  
                  // Profile Actions
                  ProfileActionsSection(
                    profile: profile,
                    onEditProfile: () => _navigateToEditProfile(context, profile),
                    onUploadImage: () => _handleImageUpload(context),
                    onDeleteImage: profile.profileImageUrl != null 
                        ? () => _handleImageDelete(context) 
                        : null,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );
    
    if (result == true) {
      // Profile was updated, refresh the data
      if (context.mounted) {
        context.read<ProfileBloc>().add(const RefreshProfile());
      }
    }
  }

  void _handleImageTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _handleImageUpload(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _handleImageUpload(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Remove Photo',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleImageDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageUpload(BuildContext context) {
    // TODO: Implement image picker functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image upload feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleImageDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Image'),
        content: const Text('Are you sure you want to delete your profile image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(const DeleteProfileImage());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper methods to extract data from different states
  dynamic _getProfileFromState(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdating) return state.currentProfile;
    if (state is ProfileUpdated) return state.profile;
    if (state is ProfileImageUploading) return state.currentProfile;
    if (state is ProfileImageUploaded) return state.profile;
    if (state is ProfileImageDeleted) return state.profile;
    if (state is ProfileError) return state.profile;
    return null;
  }

  dynamic _getCompletenessFromState(ProfileState state) {
    if (state is ProfileLoaded) return state.completeness;
    if (state is ProfileUpdated) return state.completeness;
    if (state is ProfileCompletenessLoaded) return state.completeness;
    return null;
  }
}
