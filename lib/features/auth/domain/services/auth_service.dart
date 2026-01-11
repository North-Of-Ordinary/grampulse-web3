import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Enum representing the available user roles in the GramPulse app
enum UserRole {
  citizen,
  volunteer,
  officer,
  admin,
  none
}

/// Service class to manage user authentication and role-based navigation
class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // User authentication state
  bool _isAuthenticated = false;
  bool _isAuthenticationInProgress = false; // Added to track auth in progress state
  UserRole _userRole = UserRole.none;
  String? _userId;
  String? _userName;
  String? _phoneNumber;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthenticationInProgress => _isAuthenticationInProgress; // Getter for auth in progress
  UserRole get userRole => _userRole;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get phoneNumber => _phoneNumber;

  /// Initialize the authentication state (e.g., from local storage)
  Future<void> init() async {
    // TODO: Implement loading auth state from secure storage
    // For now, default to not authenticated
    _isAuthenticated = false;
    _isAuthenticationInProgress = false;
    _userRole = UserRole.none;
  }

  /// Set the authentication as in progress after OTP verification
  void setAuthenticationInProgress({required String phoneNumber}) {
    _isAuthenticationInProgress = true;
    _phoneNumber = phoneNumber;
    // We don't set _isAuthenticated = true yet because user needs to complete profile setup
    
    // TODO: Save partial auth state to secure storage
  }

  /// Set the user as authenticated with the given role
  void setAuthenticated({
    required UserRole role,
    required String userId,
    required String userName,
    required String phoneNumber,
  }) {
    _isAuthenticated = true;
    _isAuthenticationInProgress = false;
    _userRole = role;
    _userId = userId;
    _userName = userName;
    _phoneNumber = phoneNumber;

    // TODO: Save auth state to secure storage
  }

  /// Log the user out
  void logout() {
    _isAuthenticated = false;
    _isAuthenticationInProgress = false;
    _userRole = UserRole.none;
    _userId = null;
    _userName = null;
    _phoneNumber = null;

    // TODO: Clear auth state from secure storage
  }

  /// Get the home route for the current user role
  String getHomeRoute() {
    switch (_userRole) {
      case UserRole.citizen:
        return '/citizen/home';
      case UserRole.volunteer:
        return '/volunteer/dashboard';
      case UserRole.officer:
        return '/officer/dashboard';
      case UserRole.admin:
        return '/admin/control-room';
      case UserRole.none:
        return '/login';
    }
  }
}

/// Router redirection logic based on authentication state
String? authRedirect(BuildContext context, GoRouterState state) {
  final auth = AuthService();
  
  // Public routes that don't require authentication
  final publicRoutes = [
    '/',
    '/language-selection',
    '/login',
    // '/otp-verification', // Removed as it now uses a path parameter
  ];
  
  // Check if the current path is a public route
  if (publicRoutes.contains(state.matchedLocation) || 
      state.matchedLocation.startsWith('/otp-verification/')) {
    return null; // Allow access to public routes
  }
  
  // Setup routes are semi-protected - only accessible for authenticated users 
  // who haven't completed setup
  final setupRoutes = [
    '/profile-setup',
    '/role-selection',
  ];
  
  if (setupRoutes.contains(state.matchedLocation)) {
    if (!auth.isAuthenticated && !auth.isAuthenticationInProgress) {
      return '/login'; // Redirect to login if not authenticated and not in progress
    }
    return null; // Allow access to setup routes for authenticated users or auth in progress
  }
  
  // For all other routes, check authentication
  if (!auth.isAuthenticated && !auth.isAuthenticationInProgress) {
    return '/login'; // Redirect to login if not authenticated and not in progress
  }
  
  // Role-specific path prefixes
  final roleSpecificPaths = {
    UserRole.citizen: '/citizen/',
    UserRole.volunteer: '/volunteer/',
    UserRole.officer: '/officer/',
    UserRole.admin: '/admin/',
  };
  
  // Check if user is trying to access a route for their role
  final correctPrefix = roleSpecificPaths[auth.userRole];
  if (correctPrefix != null && !state.matchedLocation.startsWith(correctPrefix)) {
    // User is trying to access a route for a different role
    return auth.getHomeRoute(); // Redirect to their role-specific home
  }
  
  return null; // Allow access
}
