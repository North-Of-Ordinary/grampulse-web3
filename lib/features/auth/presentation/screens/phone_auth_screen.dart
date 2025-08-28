import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_events_states.dart';
import '../blocs/auth_bloc.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();
      final village = _villageController.text.trim();

      context.read<AuthBloc>().add(RequestOtpEvent(
        phone: phone,
        name: name.isNotEmpty ? name : null,
        village: village.isNotEmpty ? village : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpRequestedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.go('/otp-verification', extra: state.phone);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login or Sign Up',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Enter your phone number to continue. We will send you a 6-digit verification code.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Spacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '+91',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            hintText: '10-digit mobile number',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.md,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(8),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is PhoneAuthLoading
                          ? null
                          : () {
                              if (_phoneController.text.length == 10) {
                                context.read<PhoneAuthBloc>().add(
                                      RequestOtpEvent(
                                        phoneNumber: _phoneController.text,
                                      ),
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid 10-digit mobile number'),
                                  ),
                                );
                              }
                            },
                      child: state is PhoneAuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Get OTP'),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      icon: const Icon(Icons.mic),
                      label: const Text('Speak phone number'),
                      onPressed: () => _startVoiceInput(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
