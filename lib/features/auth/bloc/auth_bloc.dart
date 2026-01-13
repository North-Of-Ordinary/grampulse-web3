import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/features/auth/domain/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final SupabaseService _supabase = SupabaseService();

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Check Supabase auth first
      final supabaseUser = _supabase.client.auth.currentUser;
      
      if (supabaseUser != null) {
        // User is authenticated via Supabase
        debugPrint('[AuthBloc] ✅ Supabase user found: ${supabaseUser.id}');
        
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('user_role') ?? 'citizen';
        final name = prefs.getString('user_name') ?? 'User';
        
        final user = User(
          id: supabaseUser.id,
          phoneNumber: supabaseUser.phone ?? '',
          name: name,
          role: role,
          email: supabaseUser.email,
        );
        
        emit(Authenticated(
          user: user,
          token: supabaseUser.id,
          isProfileComplete: prefs.getBool('is_profile_complete') ?? false,
        ));
        return;
      }
      
      // Fall back to local storage check
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');
      final phoneNumber = prefs.getString('phone_number');
      final name = prefs.getString('user_name');
      final role = prefs.getString('user_role');
      final isProfileComplete = prefs.getBool('is_profile_complete') ?? false;

      if (token != null &&
          userId != null &&
          phoneNumber != null &&
          name != null &&
          role != null) {
        final user = User(
          id: userId,
          phoneNumber: phoneNumber,
          name: name,
          role: role,
          email: prefs.getString('user_email'),
          address: prefs.getString('user_address'),
        );

        emit(Authenticated(
          user: user,
          token: token,
          isProfileComplete: isProfileComplete,
        ));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      debugPrint('[AuthBloc] ❌ Error checking auth: $e');
      emit(AuthError(message: 'Failed to check auth status: $e'));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      debugPrint('[AuthBloc] Logging in with phone: ${event.phoneNumber}');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Use the pending role selected at entry, default to citizen if not set
      final pendingRole = prefs.getString('pending_user_role') ?? 'citizen';
      
      // Get or create user in Supabase
      final userData = await _supabase.getOrCreateUser(
        event.phoneNumber,
        name: 'User',
      );
      
      final userId = userData['id'] as String;
      final userName = userData['name'] as String? ?? 'User';
      
      await prefs.setString('auth_token', userId);
      await prefs.setString('user_id', userId);
      await prefs.setString('phone_number', event.phoneNumber);
      await prefs.setString('user_name', userName);
      await prefs.setString('user_role', pendingRole);
      await prefs.setBool('is_profile_complete', false);

      final user = User(
        id: userId,
        phoneNumber: event.phoneNumber,
        name: userName,
        role: pendingRole,
      );

      debugPrint('[AuthBloc] ✅ Login successful: $userId');
      
      emit(Authenticated(
        user: user,
        token: userId,
        isProfileComplete: false,
      ));
    } catch (e) {
      debugPrint('[AuthBloc] ❌ Login failed: $e');
      emit(AuthError(message: 'Login failed: $e'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Sign out from Supabase if authenticated
      try {
        await _supabase.client.auth.signOut();
      } catch (_) {}
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final currentState = state as Authenticated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_profile_complete', event.isProfileComplete);

      emit(Authenticated(
        user: currentState.user,
        token: currentState.token,
        isProfileComplete: event.isProfileComplete,
      ));
    }
  }
}
