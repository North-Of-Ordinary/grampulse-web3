import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/auth_events_states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final response = await _apiService.requestOtp(
        event.phone,
        name: event.name,
        village: event.village,
      );

      if (response.success) {
        emit(OtpRequestedState(
          phone: event.phone,
          message: response.message,
        ));
      } else {
        emit(AuthErrorState(message: response.message));
      }
    } catch (e) {
      emit(AuthErrorState(message: 'Failed to request OTP: $e'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final response = await _apiService.verifyOtp(event.phone, event.otp);

      if (response.success && response.data != null && response.data['token'] != null) {
        emit(AuthenticatedState(token: response.data['token']));
      } else {
        emit(AuthErrorState(message: response.message));
      }
    } catch (e) {
      emit(AuthErrorState(message: 'Failed to verify OTP: $e'));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final isAuthenticated = await _apiService.isAuthenticated();
      
      if (isAuthenticated) {
        final token = await _apiService.getToken();
        emit(AuthenticatedState(token: token!));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _apiService.clearToken();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: 'Failed to logout: $e'));
    }
  }
}
