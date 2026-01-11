part of 'otp_verification_bloc.dart';

abstract class OtpVerificationState extends Equatable {
  const OtpVerificationState();
  
  @override
  List<Object> get props => [];
}

class OtpInitial extends OtpVerificationState {}

class OtpSubmitting extends OtpVerificationState {}

class OtpVerified extends OtpVerificationState {}

class OtpError extends OtpVerificationState {
  final String message;
  
  const OtpError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class OtpResending extends OtpVerificationState {}

class OtpTimerRunning extends OtpVerificationState {
  final int timeRemaining;
  
  const OtpTimerRunning({required this.timeRemaining});
  
  @override
  List<Object> get props => [timeRemaining];
}

class OtpTimerCompleted extends OtpVerificationState {}
