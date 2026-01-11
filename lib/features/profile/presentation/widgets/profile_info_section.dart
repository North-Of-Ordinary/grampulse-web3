import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/user_profile.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserProfile profile;

  const ProfileInfoSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information
        _buildSectionCard(
          title: 'Personal Information',
          icon: Icons.person,
          children: [
            _buildInfoRow(
              icon: Icons.badge,
              label: 'Full Name',
              value: profile.name ?? 'Not set',
              isEmpty: profile.name == null,
            ),
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: profile.email ?? 'Not set',
              isEmpty: profile.email == null,
            ),
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: profile.phone,
            ),
            _buildInfoRow(
              icon: Icons.language,
              label: 'Language',
              value: _formatLanguage(profile.language),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Account Information
        _buildSectionCard(
          title: 'Account Information',
          icon: Icons.account_circle,
          children: [
            _buildInfoRow(
              icon: Icons.work,
              label: 'Role',
              value: _formatRole(profile.role),
            ),
            _buildInfoRow(
              icon: Icons.verified_user,
              label: 'Verification Status',
              value: profile.isVerified ? 'Verified' : 'Pending',
              valueColor: profile.isVerified ? Colors.green[600] : Colors.orange[600],
            ),
            _buildInfoRow(
              icon: Icons.security,
              label: 'KYC Status',
              value: _formatKycStatus(profile.kycStatus),
              valueColor: _getKycStatusColor(profile.kycStatus),
            ),
            if (profile.lastLogin != null)
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Last Login',
                value: _formatDateTime(profile.lastLogin!),
              ),
          ],
        ),
        
        // Department Information (for officers/volunteers)
        if (profile.department != null || profile.designation != null) ...[
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Department Information',
            icon: Icons.business,
            children: [
              if (profile.department != null)
                _buildInfoRow(
                  icon: Icons.domain,
                  label: 'Department',
                  value: profile.department!,
                ),
              if (profile.designation != null)
                _buildInfoRow(
                  icon: Icons.badge,
                  label: 'Designation',
                  value: profile.designation!,
                ),
              _buildInfoRow(
                icon: Icons.layers,
                label: 'Escalation Level',
                value: 'Level ${profile.escalationLevel}',
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Account Dates
        _buildSectionCard(
          title: 'Account History',
          icon: Icons.history,
          children: [
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Account Created',
              value: _formatDateTime(profile.createdAt),
            ),
            _buildInfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDateTime(profile.updatedAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Info Rows
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isEmpty = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isEmpty ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? (isEmpty ? Colors.grey[400] : Colors.grey[800]),
                  fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'kn':
        return 'Kannada';
      case 'ml':
        return 'Malayalam';
      case 'bn':
        return 'Bengali';
      case 'gu':
        return 'Gujarati';
      case 'mr':
        return 'Marathi';
      case 'pa':
        return 'Punjabi';
      default:
        return language.toUpperCase();
    }
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'citizen':
        return 'Citizen';
      case 'volunteer':
        return 'Volunteer';
      case 'officer':
        return 'Government Officer';
      case 'admin':
        return 'System Administrator';
      default:
        return role.substring(0, 1).toUpperCase() + role.substring(1);
    }
  }

  String _formatKycStatus(String kycStatus) {
    switch (kycStatus.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      default:
        return kycStatus.substring(0, 1).toUpperCase() + kycStatus.substring(1);
    }
  }

  Color _getKycStatusColor(String kycStatus) {
    switch (kycStatus.toLowerCase()) {
      case 'verified':
        return Colors.green[600]!;
      case 'rejected':
        return Colors.red[600]!;
      case 'pending':
      default:
        return Colors.orange[600]!;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);
  }
}
