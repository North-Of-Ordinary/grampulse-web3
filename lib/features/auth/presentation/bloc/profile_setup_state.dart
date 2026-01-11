part of 'profile_setup_bloc.dart';

enum ProfileSetupStatus { initial, submitting, success, failure }

class ProfileSetupState extends Equatable {
  final String fullName;
  final String email;
  final String address;
  final String pinCode;
  final File? profileImage;
  final ProfileSetupStatus status;
  final String? errorMessage;
  final String? completedRole; // Role set after successful profile setup

  const ProfileSetupState({
    this.fullName = '',
    this.email = '',
    this.address = '',
    this.pinCode = '',
    this.profileImage,
    this.status = ProfileSetupStatus.initial,
    this.errorMessage,
    this.completedRole,
  });

  bool get isValid => 
      fullName.isNotEmpty && 
      email.isNotEmpty && 
      address.isNotEmpty && 
      pinCode.isNotEmpty;

  ProfileSetupState copyWith({
    String? fullName,
    String? email,
    String? address,
    String? pinCode,
    File? profileImage,
    ProfileSetupStatus? status,
    String? errorMessage,
    String? completedRole,
  }) {
    return ProfileSetupState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      completedRole: completedRole ?? this.completedRole,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    email,
    address,
    pinCode,
    profileImage,
    status,
    errorMessage,
    completedRole,
  ];
}

class ProfileSetupInitial extends ProfileSetupState {
  const ProfileSetupInitial() : super();
}
