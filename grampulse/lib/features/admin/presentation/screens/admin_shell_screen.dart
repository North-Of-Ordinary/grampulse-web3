import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/widgets/modern_bottom_nav.dart';

class AdminShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const AdminShellScreen({
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
            icon: Icons.control_camera_outlined,
            activeIcon: Icons.control_camera,
            label: 'Control',
          ),
          ModernBottomNavItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            label: 'Depts',
          ),
          ModernBottomNavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Funds',
          ),
          ModernBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
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
    if (location.contains('/control-room')) return 0;
    if (location.contains('/department-performance')) return 1;
    if (location.contains('/fund-allocation')) return 2;
    if (location.contains('/system-configuration') || location.contains('/analytics-reports')) return 3;
    if (location.contains('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin/control-room');
        break;
      case 1:
        context.go('/admin/department-performance');
        break;
      case 2:
        context.go('/admin/fund-allocation');
        break;
      case 3:
        context.go('/admin/system-configuration');
        break;
      case 4:
        context.go('/admin/profile');
        break;
    }
  }
}
