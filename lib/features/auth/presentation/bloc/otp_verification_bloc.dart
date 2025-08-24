import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
      // Simulate API call to verify OTP
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual API call to verify OTP
      
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
      // Simulate API call to resend OTP
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Implement actual API call to resend OTP
      
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
