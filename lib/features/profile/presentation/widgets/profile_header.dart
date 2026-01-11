import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isUpdating;
  final VoidCallback? onImageTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.isUpdating = false,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    backgroundImage: profile.profileImageUrl != null 
                        ? NetworkImage(profile.profileImageUrl!)
                        : null,
                    child: profile.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.green[300],
                          )
                        : null,
                  ),
                ),
              ),
              
              // Camera icon for editing
              if (onImageTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.green[600],
                    ),
                  ),
                ),
              
              // Loading indicator
              if (isUpdating)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            profile.name ?? 'Name not set',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: profile.name != null ? Colors.white : Colors.white70,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Phone
          Text(
            profile.phone,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatRole(profile.role),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Verification Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                profile.isVerified ? Icons.verified : Icons.pending,
                size: 16,
                color: profile.isVerified ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                profile.isVerified ? 'Verified' : 'Pending Verification',
                style: TextStyle(
                  fontSize: 12,
                  color: profile.isVerified ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'citizen':
        return 'Citizen';
      case 'volunteer':
        return 'Volunteer';
      case 'officer':
        return 'Officer';
      case 'admin':
        return 'Administrator';
      default:
        return role.substring(0, 1).toUpperCase() + role.substring(1);
    }
  }
}
