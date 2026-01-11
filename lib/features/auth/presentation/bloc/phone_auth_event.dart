part of 'phone_auth_bloc.dart';

abstract class PhoneAuthEvent extends Equatable {
  const PhoneAuthEvent();

  @override
  List<Object> get props => [];
}

class RequestOtpEvent extends PhoneAuthEvent {
  final String phoneNumber;
  
  const RequestOtpEvent({required this.phoneNumber});
  
  @override
  List<Object> get props => [phoneNumber];
}
