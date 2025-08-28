// Authentication Events
abstract class AuthEvent {}

class RequestOtpEvent extends AuthEvent {
  final String phone;
  final String? name;
  final String? village;

  RequestOtpEvent({
    required this.phone,
    this.name,
    this.village,
  });
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  VerifyOtpEvent({
    required this.phone,
    required this.otp,
  });
}

class CheckAuthStatusEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// Authentication States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpRequestedState extends AuthState {
  final String phone;
  final String message;

  OtpRequestedState({
    required this.phone,
    required this.message,
  });
}

class AuthenticatedState extends AuthState {
  final String token;

  AuthenticatedState({
    required this.token,
  });
}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState({
    required this.message,
  });
}

class UnauthenticatedState extends AuthState {}
