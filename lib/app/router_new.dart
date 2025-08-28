import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/phone_auth_screen_new.dart';
import '../features/auth/presentation/screens/otp_verification_screen_new.dart';
import '../features/citizen/presentation/screens/citizen_home_screen_new.dart';

final appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpVerificationScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/citizen-home',
      name: 'citizen-home',
      builder: (context, state) => const CitizenHomeScreenNew(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.matchedLocation}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/auth'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);
