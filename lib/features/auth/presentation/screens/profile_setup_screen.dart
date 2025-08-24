import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/core/widgets/buttons.dart';
import 'package:grampulse/core/widgets/inputs.dart';
import 'package:grampulse/features/auth/presentation/bloc/profile_setup_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupBloc, ProfileSetupState>(
      listener: (context, state) {
        if (state.status == ProfileSetupStatus.success) {
          context.go('/role-selection');
        } else if (state.status == ProfileSetupStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile Setup'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Please provide your details to complete your profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ProfileImagePicker(
                  image: state.profileImage,
                  onImagePicked: (file) {
                    context.read<ProfileSetupBloc>().add(
                          ProfileSetupImagePicked(file),
                        );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _fullNameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  onChanged: (value) {
                    context.read<ProfileSetupBloc>().add(
                          ProfileSetupFullNameChanged(value),
                        );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    context.read<ProfileSetupBloc>().add(
                          ProfileSetupEmailChanged(value),
                        );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Address',
                  hint: 'Enter your address',
                  controller: _addressController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  maxLines: 3,
                  onChanged: (value) {
                    context.read<ProfileSetupBloc>().add(
                          ProfileSetupAddressChanged(value),
                        );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'PIN Code',
                  hint: 'Enter your PIN code',
                  controller: _pinCodeController,
                  prefixIcon: const Icon(Icons.pin_outlined),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    context.read<ProfileSetupBloc>().add(
                          ProfileSetupPinCodeChanged(value),
                        );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: state.isValid
                      ? () {
                          context
                              .read<ProfileSetupBloc>()
                              .add(const ProfileSetupSubmitted());
                        }
                      : () {}, // Provide an empty function for null case to satisfy non-nullable VoidCallback
                  isLoading: state.status == ProfileSetupStatus.submitting,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  final File? image;
  final Function(File) onImagePicked;

  const _ProfileImagePicker({
    Key? key,
    required this.onImagePicked,
    this.image,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(context),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: Colors.grey[300],
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null
                  ? const Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.grey,
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
