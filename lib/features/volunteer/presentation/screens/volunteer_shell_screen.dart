import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/widgets/modern_bottom_nav.dart';

class VolunteerShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const VolunteerShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Exit GramPulse?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Are you sure?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Exit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      body: RepaintBoundary(child: child),
      bottomNavigationBar: RepaintBoundary(
        child: ModernBottomNav(
        currentIndex: _getCurrentIndex(),
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          ModernBottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          ModernBottomNavItem(
            icon: Icons.verified_outlined,
            activeIcon: Icons.verified,
            label: 'Verify',
          ),
          ModernBottomNavItem(
            icon: Icons.support_agent_outlined,
            activeIcon: Icons.support_agent,
            label: 'Assist',
          ),
          ModernBottomNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Stats',
          ),
          ModernBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
        ),
      ),
      ),
    );
  }

  int _getCurrentIndex() {
    if (location.contains('/dashboard')) return 0;
    if (location.contains('/verification-queue')) return 1;
    if (location.contains('/assist-citizen')) return 2;
    if (location.contains('/performance')) return 3;
    if (location.contains('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/volunteer/dashboard');
        break;
      case 1:
        context.go('/volunteer/verification-queue');
        break;
      case 2:
        context.go('/volunteer/assist-citizen');
        break;
      case 3:
        context.go('/volunteer/performance');
        break;
      case 4:
        context.go('/volunteer/profile');
        break;
    }
  }
}
