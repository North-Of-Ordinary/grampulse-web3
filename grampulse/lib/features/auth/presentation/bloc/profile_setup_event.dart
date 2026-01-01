part of 'profile_setup_bloc.dart';

abstract class ProfileSetupEvent extends Equatable {
  const ProfileSetupEvent();

  @override
  List<Object?> get props => [];
}

class ProfileSetupFullNameChanged extends ProfileSetupEvent {
  final String fullName;

  const ProfileSetupFullNameChanged(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

class ProfileSetupEmailChanged extends ProfileSetupEvent {
  final String email;

  const ProfileSetupEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class ProfileSetupAddressChanged extends ProfileSetupEvent {
  final String address;

  const ProfileSetupAddressChanged(this.address);

  @override
  List<Object?> get props => [address];
}

class ProfileSetupPinCodeChanged extends ProfileSetupEvent {
  final String pinCode;

  const ProfileSetupPinCodeChanged(this.pinCode);

  @override
  List<Object?> get props => [pinCode];
}

class ProfileSetupImagePicked extends ProfileSetupEvent {
  final File? profileImage;

  const ProfileSetupImagePicked(this.profileImage);

  @override
  List<Object?> get props => [profileImage];
}

class ProfileSetupSubmitted extends ProfileSetupEvent {
  const ProfileSetupSubmitted();
}
