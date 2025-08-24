import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/presentation/bloc/splash_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/splash_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/language_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/language_selection_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/phone_auth_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/otp_verification_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/profile_setup_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/role_selection_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:grampulse/features/citizen/presentation/bloc/citizen_home/citizen_home_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/nearby_issues/nearby_issues_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/my_issues/my_issues_bloc.dart';
import 'package:grampulse/features/citizen/presentation/screens/citizen_home_screen.dart';

// This is a placeholder for the actual routes implementation
// We'll replace this with actual screens as we implement them
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (context) => SplashBloc(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/language-selection',
      builder: (context, state) => BlocProvider(
        create: (context) => LanguageBloc(),
        child: const LanguageSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (context) => PhoneAuthBloc(),
        child: const PhoneAuthScreen(),
      ),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final phoneNumber = state.pathParameters['phoneNumber'] ?? '';
        return BlocProvider(
          create: (context) => OtpVerificationBloc(),
          child: OtpVerificationScreen(phoneNumber: phoneNumber),
        );
      },
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => BlocProvider(
        create: (context) => ProfileSetupBloc(),
        child: const ProfileSetupScreen(),
      ),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => BlocProvider(
        create: (context) => RoleSelectionBloc(),
        child: const RoleSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CitizenHomeBloc()..add(LoadDashboard())),
          BlocProvider(create: (_) => NearbyIssuesBloc()..add(LoadNearbyIssues())),
          BlocProvider(create: (_) => MyIssuesBloc()..add(LoadMyIssues())),
        ],
        child: const CitizenHomeScreen(),
      ),
    ),
    GoRoute(
      path: '/report-issue',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Report Issue - Coming Soon'),
        ),
      ),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Explore - Coming Soon'),
        ),
      ),
    ),
    GoRoute(
      path: '/my-reports',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('My Reports - Coming Soon'),
        ),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Profile - Coming Soon'),
        ),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);
