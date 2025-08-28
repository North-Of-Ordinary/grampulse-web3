import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/features/auth/presentation/bloc/language_bloc.dart';
import 'package:grampulse/features/auth/presentation/bloc/role_selection_bloc.dart';
import 'package:grampulse/features/auth/presentation/bloc/splash_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/splash_screen.dart';
import 'package:grampulse/features/auth/presentation/screens/language_selection_screen.dart';
import 'package:grampulse/features/auth/presentation/screens/login_screen.dart';
import 'package:grampulse/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/otp_verification_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:grampulse/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:grampulse/features/auth/presentation/bloc/profile_setup_bloc.dart';

// Citizen imports
import 'package:grampulse/features/citizen/presentation/bloc/citizen_home/citizen_home_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/citizen_home/citizen_home_event.dart';
import 'package:grampulse/features/citizen/presentation/bloc/nearby_issues/nearby_issues_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/my_issues/my_issues_bloc.dart';
import 'package:grampulse/features/citizen/presentation/screens/citizen_home_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/citizen_shell_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/explore_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/my_reports_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/profile_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/report_issue_screen.dart';

// Volunteer imports
import 'package:grampulse/features/volunteer/presentation/screens/volunteer_shell_screen.dart';
import 'package:grampulse/features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import 'package:grampulse/features/volunteer/presentation/screens/verification_queue_screen.dart';
import 'package:grampulse/features/volunteer/presentation/screens/assist_citizen_screen.dart';
import 'package:grampulse/features/volunteer/presentation/screens/performance_screen.dart';

// Officer imports
import 'package:grampulse/features/officer/presentation/screens/officer_shell_screen.dart';
import 'package:grampulse/features/officer/presentation/screens/officer_dashboard_screen.dart';
import 'package:grampulse/features/officer/presentation/screens/inbox_screen.dart';
import 'package:grampulse/features/officer/presentation/screens/work_orders_screen.dart';
import 'package:grampulse/features/officer/presentation/screens/analytics_screen.dart';

// Admin imports
import 'package:grampulse/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:grampulse/features/admin/presentation/screens/control_room_screen.dart';
import 'package:grampulse/features/admin/presentation/screens/department_performance_screen.dart';
import 'package:grampulse/features/admin/presentation/screens/fund_allocation_screen.dart';
import 'package:grampulse/features/admin/presentation/screens/system_configuration_screen.dart';
import 'package:grampulse/features/admin/presentation/screens/analytics_reports_screen.dart';
import 'package:grampulse/features/auth/domain/services/auth_service.dart' as domain_auth;

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    // Get current auth state from the AuthBloc
    final authState = context.read<AuthBloc>().state;
    final location = state.matchedLocation;
  final domainAuth = domain_auth.AuthService();
    
    // Define auth paths that are accessible without authentication
    final authPaths = [
      '/',
      '/language-selection',
      '/login',
      '/otp-verification',
    ];
    
    // Check if current path is an auth path
    final inAuthPath = authPaths.any((path) => 
      location == path || location.startsWith('/otp-verification/'));
    
    // Authentication logic
  if (authState is Authenticated) {
      // If authenticated but profile not complete, go to profile setup
      if (!authState.isProfileComplete && location != '/profile-setup') {
        return '/profile-setup';
      }
      
      // If authenticated with complete profile but in auth path, redirect to home
      if (inAuthPath) {
        switch (authState.user.role) {
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
      
      // Verify role-specific access
      if (location.startsWith('/citizen') && authState.user.role != 'citizen') {
        switch (authState.user.role) {
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
      
      if (location.startsWith('/volunteer') && authState.user.role != 'volunteer') {
        switch (authState.user.role) {
          case 'citizen':
            return '/citizen/home';
          case 'officer':
            return '/officer/dashboard';
          case 'admin':
            return '/admin/control-room';
          default:
            return '/citizen/home';
        }
      }
      
      if (location.startsWith('/officer') && authState.user.role != 'officer') {
        switch (authState.user.role) {
          case 'citizen':
            return '/citizen/home';
          case 'volunteer':
            return '/volunteer/dashboard';
          case 'admin':
            return '/admin/control-room';
          default:
            return '/citizen/home';
        }
      }
      
      if (location.startsWith('/admin') && authState.user.role != 'admin') {
        switch (authState.user.role) {
          case 'citizen':
            return '/citizen/home';
          case 'volunteer':
            return '/volunteer/dashboard';
          case 'officer':
            return '/officer/dashboard';
          default:
            return '/citizen/home';
        }
      }
      
      // If authenticated and in the correct role path, allow
      return null;
    } else {
      // Allow setup routes when authentication is in progress (post-OTP verification)
      final isSetupRoute = location == '/profile-setup' || location == '/role-selection';
      if (isSetupRoute && domainAuth.isAuthenticationInProgress) {
        return null;
      }

      // If domain auth service says authenticated (post-setup), allow navigation
      if (domainAuth.isAuthenticated) {
        return null;
      }

      // If not authenticated and trying to access non-auth paths, redirect to login
      if (!inAuthPath) {
        return '/login';
      }
      
      // If not authenticated and in auth path, allow
      return null;
    }
  },
  routes: [
    // Authentication routes
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => BlocProvider(
        create: (context) => SplashBloc()..add(const CheckAuthStatusEvent()),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/language-selection',
      name: 'language_selection',
      builder: (context, state) => BlocProvider(
        create: (context) => LanguageBloc(),
        child: const LanguageSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp-verification/:phoneNumber',
      name: 'otp_verification',
      builder: (context, state) {
        final phoneNumber = state.pathParameters['phoneNumber'] ?? '';
        return BlocProvider(
          create: (_) => OtpVerificationBloc(),
          child: OtpVerificationScreen(phoneNumber: phoneNumber),
        );
      },
    ),
    GoRoute(
      path: '/profile-setup',
      name: 'profile_setup',
      builder: (context, state) => BlocProvider(
        create: (_) => ProfileSetupBloc(),
        child: const ProfileSetupScreen(),
      ),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role_selection',
      builder: (context, state) => BlocProvider(
        create: (context) => RoleSelectionBloc(),
        child: const RoleSelectionScreen(),
      ),
    ),
    
    // Citizen routes
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'citizen_shell'),
      builder: (context, state, child) {
        return CitizenShellScreen(
          child: child,
          location: state.matchedLocation,
        );
      },
      routes: [
        GoRoute(
          path: '/citizen/home',
          name: 'citizen_home',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CitizenHomeBloc()..add(const LoadDashboard())),
              BlocProvider(create: (_) => NearbyIssuesBloc()..add(LoadNearbyIssues())),
              BlocProvider(create: (_) => MyIssuesBloc()..add(LoadMyIssues())),
            ],
            child: const CitizenHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/citizen/explore',
          name: 'citizen_explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/citizen/my-reports',
          name: 'citizen_my_reports',
          builder: (context, state) => const MyReportsScreen(),
        ),
        GoRoute(
          path: '/citizen/profile',
          name: 'citizen_profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/citizen/report-issue',
          name: 'report_issue',
          builder: (context, state) => const ReportIssueScreen(),
        ),
      ],
    ),
    
    // Volunteer routes
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'volunteer_shell'),
      builder: (context, state, child) {
        return VolunteerShellScreen(
          child: child,
          location: state.matchedLocation,
        );
      },
      routes: [
        GoRoute(
          path: '/volunteer/dashboard',
          name: 'volunteer_dashboard',
          builder: (context, state) => const VolunteerDashboardScreen(),
        ),
        GoRoute(
          path: '/volunteer/verification-queue',
          name: 'volunteer_verification_queue',
          builder: (context, state) => const VerificationQueueScreen(),
        ),
        GoRoute(
          path: '/volunteer/assist-citizen',
          name: 'volunteer_assist_citizen',
          builder: (context, state) => const AssistCitizenScreen(),
        ),
        GoRoute(
          path: '/volunteer/performance',
          name: 'volunteer_performance',
          builder: (context, state) => const PerformanceScreen(),
        ),
      ],
    ),
    
    // Officer routes
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'officer_shell'),
      builder: (context, state, child) {
        return OfficerShellScreen(
          child: child,
          location: state.matchedLocation,
        );
      },
      routes: [
        GoRoute(
          path: '/officer/dashboard',
          name: 'officer_dashboard',
          builder: (context, state) => const OfficerDashboardScreen(),
        ),
        GoRoute(
          path: '/officer/inbox',
          name: 'officer_inbox',
          builder: (context, state) => const InboxScreen(),
        ),
        GoRoute(
          path: '/officer/work-orders',
          name: 'officer_work_orders',
          builder: (context, state) => const WorkOrdersScreen(),
        ),
        GoRoute(
          path: '/officer/analytics',
          name: 'officer_analytics',
          builder: (context, state) => const OfficerAnalyticsScreen(),
        ),
      ],
    ),
    
    // Admin routes
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'admin_shell'),
      builder: (context, state, child) {
        return AdminShellScreen(
          child: child,
          location: state.matchedLocation,
        );
      },
      routes: [
        GoRoute(
          path: '/admin/control-room',
          name: 'admin_control_room',
          builder: (context, state) => const ControlRoomScreen(),
        ),
        GoRoute(
          path: '/admin/department-performance',
          name: 'admin_department_performance',
          builder: (context, state) => const DepartmentPerformanceScreen(),
        ),
        GoRoute(
          path: '/admin/fund-allocation',
          name: 'admin_fund_allocation',
          builder: (context, state) => const FundAllocationScreen(),
        ),
        GoRoute(
          path: '/admin/system-configuration',
          name: 'admin_system_configuration',
          builder: (context, state) => const SystemConfigurationScreen(),
        ),
        GoRoute(
          path: '/admin/analytics-reports',
          name: 'admin_analytics_reports',
          builder: (context, state) => const AnalyticsReportsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);
