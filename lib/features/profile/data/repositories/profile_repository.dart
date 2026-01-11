import 'dart:io';
import '../../../../core/services/api_service.dart';
import '../models/user_profile.dart';
import '../models/profile_completeness.dart';
import '../models/profile_update_request.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  /// Get current user profile
  Future<UserProfile?> getProfile() async {
    try {
      print('📖 REPOSITORY: Getting user profile');
      
      final response = await _apiService.getProfile();
      
      if (response.success && response.data != null) {
        print('✅ REPOSITORY: Profile retrieved successfully');
        return UserProfile.fromJson(response.data!);
      } else {
        print('❌ REPOSITORY: Failed to get profile: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ REPOSITORY: Get profile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserProfile?> updateProfile(ProfileUpdateRequest request) async {
    try {
      print('✏️ REPOSITORY: Updating user profile');
      print('📝 REPOSITORY: Update data: ${request.toJson()}');
      
      final response = await _apiService.updateProfile(request.toJson());
      
      if (response.success && response.data != null) {
        print('✅ REPOSITORY: Profile updated successfully');
        return UserProfile.fromJson(response.data!);
      } else {
        print('❌ REPOSITORY: Failed to update profile: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ REPOSITORY: Update profile error: $e');
      rethrow;
    }
  }

  /// Get profile completeness information
  Future<ProfileCompleteness?> getProfileCompleteness() async {
    try {
      print('🔍 REPOSITORY: Getting profile completeness');
      
      final response = await _apiService.getProfileCompleteness();
      
      if (response.success && response.data != null) {
        print('✅ REPOSITORY: Profile completeness retrieved successfully');
        return ProfileCompleteness.fromJson(response.data!);
      } else {
        print('❌ REPOSITORY: Failed to get profile completeness: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ REPOSITORY: Get profile completeness error: $e');
      rethrow;
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      print('📸 REPOSITORY: Uploading profile image');
      
      final response = await _apiService.uploadProfileImage(imageFile);
      
      if (response.success && response.data != null) {
        print('✅ REPOSITORY: Profile image uploaded successfully');
        final profileImageUrl = response.data!['profileImageUrl'] as String?;
        return profileImageUrl;
      } else {
        print('❌ REPOSITORY: Failed to upload profile image: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ REPOSITORY: Upload profile image error: $e');
      rethrow;
    }
  }

  /// Delete profile image
  Future<bool> deleteProfileImage() async {
    try {
      print('🗑️ REPOSITORY: Deleting profile image');
      
      final response = await _apiService.deleteProfileImage();
      
      if (response.success) {
        print('✅ REPOSITORY: Profile image deleted successfully');
        return true;
      } else {
        print('❌ REPOSITORY: Failed to delete profile image: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ REPOSITORY: Delete profile image error: $e');
      rethrow;
    }
  }
}
