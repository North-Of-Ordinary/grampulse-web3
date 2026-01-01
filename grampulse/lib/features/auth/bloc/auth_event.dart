// Authentication Events
abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const LoginEvent({
    required this.phoneNumber,
    required this.otp,
  });
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final bool isProfileComplete;

  const UpdateProfileEvent({
    required this.isProfileComplete,
  });
}
