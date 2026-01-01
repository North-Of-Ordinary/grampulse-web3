import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/features/auth/domain/services/auth_service.dart';
import 'package:grampulse/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'otp_verification_event.dart';
part 'otp_verification_state.dart';

class OtpVerificationBloc extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  OtpVerificationBloc() : super(OtpInitial()) {
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<StartTimerEvent>(_onStartTimer);
    on<TimerTickEvent>(_onTimerTick);
  }

  Timer? _timer;
  static const int timerDuration = 45;

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<OtpVerificationState> emit,
  ) async {
    emit(OtpSubmitting());
    
    try {
      final api = ApiService();
      final resp = await api.post(
        '/auth/verify-otp',
        {
          'phone': event.phoneNumber,
          'otp': event.otp,
        },
        (data) => data,
      );

      if (!resp.success || resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception(resp.message);
      }

      final data = resp.data as Map<String, dynamic>?;
      final token = data?['token'] as String?;
      if (token != null) {
        await api.saveToken(token);
      }
      
      // Save phone number to SharedPreferences for later use in profile setup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone_number', event.phoneNumber);

      final authService = AuthService();
      authService.setAuthenticationInProgress(phoneNumber: event.phoneNumber);

      emit(OtpVerified());
    } catch (e) {
      emit(OtpError(message: e.toString()));
    }
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<OtpVerificationState> emit,
  ) async {
    emit(OtpResending());
    try {
      final api = ApiService();
      final resp = await api.post(
        '/auth/request-otp',
        {
          'phone': event.phoneNumber,
        },
        (data) => data,
      );
      if (!resp.success) throw Exception(resp.message);
      emit(OtpInitial());
      add(const StartTimerEvent());
    } catch (e) {
      emit(OtpError(message: e.toString()));
    }
  }
  
  Future<void> _onStartTimer(
    StartTimerEvent event,
    Emitter<OtpVerificationState> emit,
  ) async {
    _cancelTimer();
    
    emit(OtpTimerRunning(timeRemaining: timerDuration));
    
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => add(TimerTickEvent(timeRemaining: timerDuration - timer.tick)),
    );
  }
  
  void _onTimerTick(
    TimerTickEvent event,
    Emitter<OtpVerificationState> emit,
  ) {
    if (event.timeRemaining > 0) {
      emit(OtpTimerRunning(timeRemaining: event.timeRemaining));
    } else {
      _cancelTimer();
      emit(OtpTimerCompleted());
    }
  }
  
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
