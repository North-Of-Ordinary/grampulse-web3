import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/core/presentation/theme/theme_cubit.dart';
import 'package:grampulse/core/theme/color_schemes.dart';
import 'help_support_screen.dart';

/// A Grok-inspired minimal profile screen with clean UI/UX.
/// Features a modern, distraction-free design with clear sections.
class GrokProfileScreen extends StatelessWidget {
  const GrokProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate to entry role selection when user logs out
        if (state is Unauthenticated) {
          context.go('/entry-role-selection');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _ProfileContent(user: state.user);
          }

          // Fallback for unauthenticated state - show loading while redirecting
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final User user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkSurfaces.level0 : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? DarkSurfaces.level1 : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              _navigateToHome(context);
            }
          },
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // Better performance than bouncing
        child: RepaintBoundary(
          child: Column(
          children: [
            const SizedBox(height: 8),

            // Profile Avatar & Basic Info
            _buildProfileHeader(context, colorScheme, isDark),

            const SizedBox(height: 32),

            // Personal Information Section
            _buildSectionHeader(context, 'Personal Information'),
            _buildInfoSection(context, colorScheme, isDark),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader(context, 'Preferences'),
            _buildPreferencesSection(context, colorScheme, isDark),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, 'Support'),
            _buildSupportSection(context, colorScheme, isDark, user.role),

            const SizedBox(height: 24),

            // Logout Button
            _buildLogoutButton(context, colorScheme),

            const SizedBox(height: 40),

            // App Version
            _buildAppVersion(context, colorScheme),

            const SizedBox(height: 24),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? DarkSurfaces.level3
                  : colorScheme.primaryContainer,
              border: Border.all(
                color: isDark ? DarkSurfaces.borderMedium : colorScheme.outline.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(user.name),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? colorScheme.onSurface
                      : colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatRole(user.role),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _getRoleColor(user.role),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? DarkSurfaces.level2
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _ProfileListTile(
            icon: Icons.person_outline_rounded,
            title: 'Name',
            subtitle: user.name,
            showDivider: true,
          ),
          _ProfileListTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: user.phoneNumber,
            showDivider: user.email != null || user.address != null,
          ),
          if (user.email != null && user.email!.isNotEmpty)
            _ProfileListTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: user.email!,
              showDivider: user.address != null,
            ),
          if (user.address != null && user.address!.isNotEmpty)
            _ProfileListTile(
              icon: Icons.location_on_outlined,
              title: 'Address',
              subtitle: user.address!,
              showDivider: false,
            ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? DarkSurfaces.level2
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Dark Mode Toggle (Grok-style)
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDarkMode = themeMode == ThemeMode.dark;
              return _ProfileActionTile(
                icon: isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  activeColor: colorScheme.primary,
                ),
                showDivider: true,
              );
            },
          ),
          _ProfileActionTile(
            icon: Icons.language_rounded,
            title: 'Language',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'English',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to language selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            showDivider: true,
          ),
          _ProfileActionTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onTap: () {
              // TODO: Navigate to notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(
      BuildContext context, ColorScheme colorScheme, bool isDark, String userRole) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? DarkSurfaces.level2
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _ProfileActionTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & FAQ',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HelpSupportScreen(userRole: userRole),
                ),
              );
            },
            showDivider: true,
          ),
          _ProfileActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            showDivider: true,
          ),
          _ProfileActionTile(
            icon: Icons.info_outline_rounded,
            title: 'About GramPulse',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onTap: () {
              _showAboutDialog(context);
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'GramPulse',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Version 2.0.2',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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
        return role[0].toUpperCase() + role.substring(1);
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'citizen':
        return const Color(0xFF4CAF50); // Green
      case 'volunteer':
        return const Color(0xFF2196F3); // Blue
      case 'officer':
        return const Color(0xFFFF9800); // Orange
      case 'admin':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  void _navigateToHome(BuildContext context) {
    switch (user.role.toLowerCase()) {
      case 'citizen':
        context.go('/citizen/home');
        break;
      case 'volunteer':
        context.go('/volunteer/dashboard');
        break;
      case 'officer':
        context.go('/officer/dashboard');
        break;
      case 'admin':
        context.go('/admin/control-room');
        break;
      default:
        context.go('/citizen/home');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Dispatch logout event - BlocListener will handle navigation
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GramPulse',
      applicationVersion: '2.0.2',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.local_fire_department_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'GramPulse is a civic engagement platform connecting citizens, volunteers, and officials to improve local communities.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A list tile for displaying user information
class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
      ],
    );
  }
}

/// A list tile for actionable items
class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? null
              : const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
      ],
    );
  }
}
