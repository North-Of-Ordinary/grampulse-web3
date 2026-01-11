part of 'phone_auth_bloc.dart';

abstract class PhoneAuthState extends Equatable {
  const PhoneAuthState();
  
  @override
  List<Object> get props => [];
}

class PhoneAuthInitial extends PhoneAuthState {}

class PhoneAuthLoading extends PhoneAuthState {}

class PhoneAuthSuccess extends PhoneAuthState {
  final String phoneNumber;
  
  const PhoneAuthSuccess({required this.phoneNumber});
  
  @override
  List<Object> get props => [phoneNumber];
}

class PhoneAuthFailure extends PhoneAuthState {
  final String error;
  
  const PhoneAuthFailure({required this.error});
  
  @override
  List<Object> get props => [error];
}
