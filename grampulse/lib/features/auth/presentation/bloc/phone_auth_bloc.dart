import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  PhoneAuthBloc() : super(PhoneAuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthLoading());
    
    try {
      // Simulate API call to request OTP
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual API call to request OTP
      
      emit(PhoneAuthSuccess(phoneNumber: event.phoneNumber));
    } catch (e) {
      emit(PhoneAuthFailure(error: e.toString()));
    }
  }
}
