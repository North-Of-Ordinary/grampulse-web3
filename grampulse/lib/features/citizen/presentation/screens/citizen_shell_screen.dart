import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/widgets/modern_bottom_nav.dart';

/// Shell screen for Citizen user role
/// Provides bottom navigation between:
/// - Home
/// - Explore
/// - My Reports
/// - Profile
class CitizenShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const CitizenShellScreen({
    required this.child,
    required this.location,
    Key? key,
  }) : super(key: key);

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
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: RepaintBoundary(
        child: _buildBottomNavigationBar(context),
      ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    // Only show FAB on Home and Explore tabs
    if (location == '/citizen/home' || location == '/citizen/explore') {
      return FloatingActionButton.extended(
          heroTag: "report_issue_fab_$location", // Unique hero tag
          onPressed: () => context.push('/citizen/report-issue'),
          label: const Text('Report Issue'),
        icon: const Icon(Icons.add_circle),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return ModernBottomNav(
      currentIndex: _calculateSelectedIndex(location),
      onTap: (int idx) => _onItemTapped(idx, context),
      items: const [
        ModernBottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        ModernBottomNavItem(
          icon: Icons.explore_outlined,
          activeIcon: Icons.explore,
          label: 'Explore',
        ),
        ModernBottomNavItem(
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment,
          label: 'My Reports',
        ),
        ModernBottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/citizen/home')) return 0;
    if (location.startsWith('/citizen/explore')) return 1;
    if (location.startsWith('/citizen/my-reports')) return 2;
    if (location.startsWith('/citizen/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed('citizen_home');
        break;
      case 1:
        context.goNamed('citizen_explore');
        break;
      case 2:
        context.goNamed('citizen_my_reports');
        break;
      case 3:
        context.goNamed('citizen_profile');
        break;
    }
  }
}
