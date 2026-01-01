import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:grampulse/features/auth/domain/services/auth_service.dart';
import 'package:grampulse/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_setup_event.dart';
part 'profile_setup_state.dart';

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  ProfileSetupBloc() : super(ProfileSetupInitial()) {
    on<ProfileSetupFullNameChanged>(_onFullNameChanged);
    on<ProfileSetupEmailChanged>(_onEmailChanged);
    on<ProfileSetupAddressChanged>(_onAddressChanged);
    on<ProfileSetupPinCodeChanged>(_onPinCodeChanged);
    on<ProfileSetupImagePicked>(_onImagePicked);
    on<ProfileSetupSubmitted>(_onSubmitted);
  }

  FutureOr<void> _onFullNameChanged(
    ProfileSetupFullNameChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    emit(state.copyWith(fullName: event.fullName));
  }

  FutureOr<void> _onEmailChanged(
    ProfileSetupEmailChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _onAddressChanged(
    ProfileSetupAddressChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    emit(state.copyWith(address: event.address));
  }

  FutureOr<void> _onPinCodeChanged(
    ProfileSetupPinCodeChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    emit(state.copyWith(pinCode: event.pinCode));
  }

  FutureOr<void> _onImagePicked(
    ProfileSetupImagePicked event,
    Emitter<ProfileSetupState> emit,
  ) {
    emit(state.copyWith(profileImage: event.profileImage));
  }

  FutureOr<void> _onSubmitted(
    ProfileSetupSubmitted event,
    Emitter<ProfileSetupState> emit,
  ) async {
    emit(state.copyWith(status: ProfileSetupStatus.submitting));
    
    try {
      // Get the pending role selected at entry
      final prefs = await SharedPreferences.getInstance();
      final pendingRole = prefs.getString('pending_user_role') ?? 'citizen';
      
      final api = ApiService();
      final body = {
        'name': state.fullName,
        'role': pendingRole,
        'email': state.email,
      };

      final resp = await api.put('/auth/complete-profile', body, (d) => d);
      if (!resp.success) throw Exception(resp.message);

      // Get the auth token (could be stored as 'token' by api_service)
      String? authToken = prefs.getString('auth_token') ?? prefs.getString('token');
      
      // Save ALL required fields for AuthBloc to recognize as authenticated
      await prefs.setString('user_role', pendingRole);
      await prefs.setBool('is_profile_complete', true);
      await prefs.setString('user_name', state.fullName);
      await prefs.setString('user_email', state.email);
      await prefs.setString('user_address', state.address);
      
      // Ensure auth_token is set (copy from 'token' if needed)
      if (authToken != null) {
        await prefs.setString('auth_token', authToken);
      }
      
      // Set user_id if not already set (use a placeholder or fetch from API response)
      if (prefs.getString('user_id') == null) {
        // Try to get from API response or use phone number as fallback
        final data = resp.data as Map<String, dynamic>?;
        final userId = data?['user_id']?.toString() ?? 
                       data?['id']?.toString() ?? 
                       prefs.getString('phone_number') ?? 
                       'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('user_id', userId);
      }

      // Keep auth as in-progress; navigation will be handled by the screen
      final authService = AuthService();
      if (authService.phoneNumber == null) {
        // no-op, just ensure service is initialized
      }

      emit(state.copyWith(
        status: ProfileSetupStatus.success,
        completedRole: pendingRole,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileSetupStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
