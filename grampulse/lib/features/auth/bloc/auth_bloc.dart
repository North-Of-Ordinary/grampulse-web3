import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/features/auth/domain/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

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
      emit(AuthError(message: 'Failed to check auth status: $e'));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Simulate login - in real app, this would call API
      final prefs = await SharedPreferences.getInstance();
      
      // Use the pending role selected at entry, default to citizen if not set
      final pendingRole = prefs.getString('pending_user_role') ?? 'citizen';
      
      await prefs.setString('auth_token', 'dummy_token');
      await prefs.setString('user_id', '1');
      await prefs.setString('phone_number', event.phoneNumber);
      await prefs.setString('user_name', 'User');
      await prefs.setString('user_role', pendingRole);
      await prefs.setBool('is_profile_complete', false);

      final user = User(
        id: '1',
        phoneNumber: event.phoneNumber,
        name: 'User',
        role: pendingRole,
      );

      emit(Authenticated(
        user: user,
        token: 'dummy_token',
        isProfileComplete: false,
      ));
    } catch (e) {
      emit(AuthError(message: 'Login failed: $e'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
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
