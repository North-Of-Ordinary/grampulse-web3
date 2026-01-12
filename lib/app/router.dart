import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart' as auth_events;
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/features/auth/presentation/bloc/language_bloc.dart';
import 'package:grampulse/features/auth/presentation/bloc/role_selection_bloc.dart';
import 'package:grampulse/features/auth/presentation/screens/splash_screen.dart';
import 'package:grampulse/features/auth/presentation/screens/entry_role_selection_screen.dart';
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
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_bloc.dart';
import 'package:grampulse/features/citizen/domain/repositories/incident_repository.dart';
import 'package:grampulse/features/citizen/presentation/screens/citizen_home_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/citizen_shell_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/explore_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/my_reports_screen.dart';
import 'package:grampulse/features/profile/presentation/screens/grok_profile_screen.dart';
import 'package:grampulse/features/citizen/presentation/screens/report_issue_screen.dart';

// Report/Attestation imports
import 'package:grampulse/features/report/presentation/bloc/attestation_bloc.dart';
import 'package:grampulse/features/report/presentation/screens/attestation_verification_screen.dart';

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

// PHASE 5: Web3 Governance & Transparency imports
import 'package:grampulse/features/dashboard/presentation/screens/transparency_dashboard_screen.dart';
import 'package:grampulse/features/dashboard/presentation/bloc/dashboard_bloc.dart' as web3_dashboard;
import 'package:grampulse/features/governance/presentation/screens/governance_screen.dart';
import 'package:grampulse/features/governance/presentation/bloc/governance_bloc.dart';
import 'package:grampulse/features/reputation/presentation/screens/leaderboard_screen.dart';
import 'package:grampulse/features/reputation/presentation/bloc/reputation_bloc.dart';

// No transition for instant tab switching within shell routes
Page<T> buildPageWithNoTransition<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<T>(
    key: state.pageKey,
    child: child,
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false, // Disable debug logging for better performance
  redirect: (context, state) {
    // Get current auth state from the AuthBloc
    final authState = context.read<AuthBloc>().state;
    final location = state.matchedLocation;
  final domainAuth = domain_auth.AuthService();
    
    // Define auth paths that are accessible without authentication
    final authPaths = [
      '/',
      '/entry-role-selection',
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

      // If not authenticated and trying to access non-auth paths, redirect to entry role selection
      if (!inAuthPath) {
        return '/entry-role-selection';
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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/entry-role-selection',
      name: 'entry_role_selection',
      builder: (context, state) => const EntryRoleSelectionScreen(),
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
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CitizenHomeBloc()..add(const LoadDashboard())),
              BlocProvider(create: (_) => NearbyIssuesBloc()..add(LoadNearbyIssues())),
              BlocProvider(create: (_) => MyIssuesBloc()..add(LoadMyIssues())),
            ],
            child: const CitizenHomeScreen(),
          ),
          ),
        ),
        GoRoute(
          path: '/citizen/explore',
          name: 'citizen_explore',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: BlocProvider(
            create: (context) => IncidentBloc(
              repository: context.read<IncidentRepository>(),
            ),
            child: const ExploreScreen(),
          ),
          ),
        ),
        GoRoute(
          path: '/citizen/my-reports',
          name: 'citizen_my_reports',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const MyReportsScreen(),
          ),
        ),
        GoRoute(
          path: '/citizen/profile',
          name: 'citizen_profile',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const GrokProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/citizen/report-issue',
          name: 'report_issue',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const ReportIssueScreen(),
          ),
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
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const VolunteerDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/volunteer/verification-queue',
          name: 'volunteer_verification_queue',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const VerificationQueueScreen(),
          ),
        ),
        GoRoute(
          path: '/volunteer/assist-citizen',
          name: 'volunteer_assist_citizen',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const AssistCitizenScreen(),
          ),
        ),
        GoRoute(
          path: '/volunteer/performance',
          name: 'volunteer_performance',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const PerformanceScreen(),
          ),
        ),
        GoRoute(
          path: '/volunteer/profile',
          name: 'volunteer_profile',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const GrokProfileScreen(),
          ),
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
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const OfficerDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/officer/inbox',
          name: 'officer_inbox',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const InboxScreen(),
          ),
        ),
        GoRoute(
          path: '/officer/work-orders',
          name: 'officer_work_orders',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const WorkOrdersScreen(),
          ),
        ),
        GoRoute(
          path: '/officer/analytics',
          name: 'officer_analytics',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const OfficerAnalyticsScreen(),
          ),
        ),
        GoRoute(
          path: '/officer/profile',
          name: 'officer_profile',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const GrokProfileScreen(),
          ),
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
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const ControlRoomScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/department-performance',
          name: 'admin_department_performance',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const DepartmentPerformanceScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/fund-allocation',
          name: 'admin_fund_allocation',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const FundAllocationScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/system-configuration',
          name: 'admin_system_configuration',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const SystemConfigurationScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/analytics-reports',
          name: 'admin_analytics_reports',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const AnalyticsReportsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/profile',
          name: 'admin_profile',
          pageBuilder: (context, state) => buildPageWithNoTransition(
            state: state,
            child: const GrokProfileScreen(),
          ),
        ),
      ],
    ),
    
    // Shared routes (accessible from any authenticated role)
    GoRoute(
      path: '/verify-attestation',
      name: 'verify_attestation',
      builder: (context, state) {
        final uid = state.uri.queryParameters['uid'];
        return BlocProvider<AttestationBloc>(
          create: (context) => AttestationBloc(),
          child: AttestationVerificationScreen(initialUid: uid),
        );
      },
    ),
    
    // PHASE 5: Web3 Transparency & Governance routes
    GoRoute(
      path: '/transparency-dashboard',
      name: 'transparency_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => web3_dashboard.DashboardBloc()..add(web3_dashboard.LoadDashboard()),
        child: const TransparencyDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/governance',
      name: 'governance',
      builder: (context, state) => BlocProvider(
        create: (_) => GovernanceBloc()..add(LoadGovernanceParams()),
        child: const GovernanceScreen(),
      ),
    ),
    GoRoute(
      path: '/leaderboard',
      name: 'leaderboard',
      builder: (context, state) => BlocProvider(
        create: (_) => ReputationBloc()..add(const LoadLeaderboard()),
        child: const LeaderboardScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);
