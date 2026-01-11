import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grampulse/core/theme/spacing.dart';

/// Entry screen shown at app launch for role selection.
/// 
/// This screen allows users to select their role (Citizen, Volunteer, or Officer)
/// BEFORE proceeding to authentication. The selected role is stored and used
/// throughout the authentication flow to determine the appropriate dashboard
/// and features.
class EntryRoleSelectionScreen extends StatefulWidget {
  const EntryRoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<EntryRoleSelectionScreen> createState() => _EntryRoleSelectionScreenState();
}

class _EntryRoleSelectionScreenState extends State<EntryRoleSelectionScreen> {
  String? _selectedRole;

  Future<void> _continueWithRole() async {
    if (_selectedRole == null) return;

    // Store the selected role for use during authentication
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_user_role', _selectedRole!);

    if (mounted) {
      // Continue to language selection → login flow
      context.go('/language-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Header
                Text(
                  'Welcome to GramPulse',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'How would you like to use the app?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Role Cards
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _EntryRoleCard(
                          title: 'Citizen',
                          description: 'Report issues in your area and track their resolution',
                          icon: Icons.person_rounded,
                          isSelected: _selectedRole == 'citizen',
                          onTap: () => setState(() => _selectedRole = 'citizen'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _EntryRoleCard(
                          title: 'Volunteer',
                          description: 'Verify issues and help coordinate with officials',
                          icon: Icons.volunteer_activism_rounded,
                          isSelected: _selectedRole == 'volunteer',
                          onTap: () => setState(() => _selectedRole = 'volunteer'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _EntryRoleCard(
                          title: 'Government Officer',
                          description: 'Manage and respond to reported issues',
                          icon: Icons.account_balance_rounded,
                          isSelected: _selectedRole == 'officer',
                          onTap: () => setState(() => _selectedRole = 'officer'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Continue Button
                FilledButton(
                  onPressed: _selectedRole != null ? _continueWithRole : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

/// Role card widget for entry role selection
class _EntryRoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EntryRoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primaryContainer 
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected 
                    ? colorScheme.primary 
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? colorScheme.onPrimaryContainer 
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
