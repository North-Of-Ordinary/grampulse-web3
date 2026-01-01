import 'package:equatable/equatable.dart';

// User model for authentication
class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String name;
  final String role;
  final String? email;
  final String? address;

  const User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.role,
    this.email,
    this.address,
  });

  @override
  List<Object?> get props => [id, phoneNumber, name, role, email, address];
}

// Authentication States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  final String token;
  final bool isProfileComplete;

  const Authenticated({
    required this.user,
    required this.token,
    required this.isProfileComplete,
  });

  @override
  List<Object?> get props => [user, token, isProfileComplete];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
