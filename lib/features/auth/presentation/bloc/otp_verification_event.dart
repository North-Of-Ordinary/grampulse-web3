part of 'otp_verification_bloc.dart';

abstract class OtpVerificationEvent extends Equatable {
  const OtpVerificationEvent();

  @override
  List<Object> get props => [];
}

class VerifyOtpEvent extends OtpVerificationEvent {
  final String otp;
  final String phoneNumber;
  
  const VerifyOtpEvent({required this.otp, required this.phoneNumber});
  
  @override
  List<Object> get props => [otp, phoneNumber];
}

class ResendOtpEvent extends OtpVerificationEvent {
  final String phoneNumber;
  
  const ResendOtpEvent({required this.phoneNumber});
  
  @override
  List<Object> get props => [phoneNumber];
}

class StartTimerEvent extends OtpVerificationEvent {
  const StartTimerEvent();
}

class TimerTickEvent extends OtpVerificationEvent {
  final int timeRemaining;
  
  const TimerTickEvent({required this.timeRemaining});
  
  @override
  List<Object> get props => [timeRemaining];
}
