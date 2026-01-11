import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/config/app_config.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart' as auth_events;
import 'package:shared_preferences/shared_preferences.dart';

/// A testing-only authentication bypass button.
/// 
/// This widget provides a quick way to skip authentication during development
/// and testing. It creates a mock authenticated state with a default test user.
/// 
/// SECURITY NOTES:
/// - Only visible when [AppConfig.showAuthBypass] is true (debug mode + flag)
/// - Automatically hidden in release builds via kDebugMode check
/// - Does NOT affect production authentication behavior
/// - Can be completely removed by:
///   1. Setting [AppConfig.enableAuthBypass] to false, OR
///   2. Removing this widget from authentication screens
/// 
/// USAGE GUIDELINES:
/// - Use ONLY on authentication screens (login, OTP, profile setup)
/// - Do NOT use on the entry/role selection screen
/// - The button should appear AFTER a role is selected, not before
/// 
/// Usage:
/// ```dart
/// // Wrap your screen body
/// TestAuthBypassButton.wrapScreen(
///   child: YourScreenContent(),
/// )
/// ```
class TestAuthBypassButton extends StatelessWidget {
  /// The role to assign to the test user.
  /// Defaults to 'citizen'.
  final String testRole;

  const TestAuthBypassButton({
    super.key,
    this.testRole = 'citizen',
  });

  /// Wraps a screen with the bypass button positioned at bottom-right.
  /// Returns the child unchanged if bypass is disabled.
  static Widget wrapScreen({
    required Widget child,
    String testRole = 'citizen',
  }) {
    // Don't wrap if bypass is disabled
    if (!AppConfig.showAuthBypass) {
      debugPrint('TestAuthBypassButton: Bypass disabled, not showing button');
      return child;
    }
    
    debugPrint('TestAuthBypassButton: Bypass enabled, wrapping screen with button');
    
    return Stack(
      children: [
        // Original content fills the stack
        Positioned.fill(child: child),
        // Bypass button at bottom-right
        Positioned(
          bottom: 24,
          right: 16,
          child: SafeArea(
            child: _BypassButtonContent(testRole: testRole),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't render anything if bypass is disabled
    if (!AppConfig.showAuthBypass) {
      return const SizedBox.shrink();
    }

    return _BypassButtonContent(testRole: testRole);
  }
}

/// Internal widget containing the actual button UI and logic
class _BypassButtonContent extends StatelessWidget {
  final String testRole;

  const _BypassButtonContent({required this.testRole});

  Future<void> _bypassAuth(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Set mock authentication data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Use the pending role selected on entry screen, fallback to passed testRole, then 'citizen'
      final selectedRole = prefs.getString('pending_user_role') ?? testRole;
      
      await prefs.setString('auth_token', 'test_bypass_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_id', 'test_user_001');
      await prefs.setString('phone_number', '9999999999');
      await prefs.setString('user_name', 'Test User');
      await prefs.setString('user_role', selectedRole);
      await prefs.setBool('is_profile_complete', true);

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Trigger AuthBloc to check status and update state
      if (context.mounted) {
        context.read<AuthBloc>().add(const auth_events.CheckAuthStatusEvent());
      }

      // Wait a moment for state to update, then navigate
      await Future.delayed(const Duration(milliseconds: 150));

      if (context.mounted) {
        // Navigate to role-specific dashboard using GoRouter
        // Use selectedRole which respects the pending_user_role from entry selection
        final route = _getRouteForRole(selectedRole);
        context.go(route);
      }
    } catch (e) {
      // Dismiss loading dialog on error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bypass failed: $e')),
        );
      }
    }
  }

  String _getRouteForRole(String role) {
    switch (role) {
      case 'citizen':
        return '/citizen/home';
      case 'volunteer':
        return '/volunteer/dashboard';
      case 'officer':
        return '/officer/dashboard';
      case 'admin':
        return '/admin/control-room';
      default:
        return '/citizen/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TestAuthBypassButton: Building button content');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _bypassAuth(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bug_report,
                size: 20,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text(
                'Skip for Testing',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
