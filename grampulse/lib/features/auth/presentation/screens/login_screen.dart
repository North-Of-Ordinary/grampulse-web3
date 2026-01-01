import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/core/widgets/test_auth_bypass_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showOtpField = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showOtpField = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP: 123456 (Demo)')),
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text.isNotEmpty) {
      context.read<AuthBloc>().add(LoginEvent(
            phoneNumber: _phoneController.text,
            otp: _otpController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: TestAuthBypassButton.wrapScreen(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              if (!state.isProfileComplete) {
                context.go('/profile-setup');
              } else {
                // Navigate based on role
                switch (state.user.role) {
                  case 'citizen':
                    context.go('/citizen/home');
                    break;
                  case 'volunteer':
                    context.go('/volunteer/dashboard');
                    break;
                  case 'officer':
                    context.go('/officer/dashboard');
                    break;
                  case 'admin':
                    context.go('/admin/control-room');
                    break;
                  default:
                    context.go('/citizen/home');
                }
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome to GramPulse',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      enabled: !_showOtpField && !isLoading,
                    ),
                    if (_showOtpField) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'OTP',
                          hintText: 'Enter OTP (Demo: 123456)',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter OTP';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (!_showOtpField)
                      ElevatedButton(
                        onPressed: isLoading ? null : _requestOtp,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Request OTP'),
                      )
                    else
                      ElevatedButton(
                        onPressed: isLoading ? null : _verifyOtp,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Verify OTP'),
                      ),
                    if (_showOtpField) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showOtpField = false;
                            _otpController.clear();
                          });
                        },
                        child: const Text('Change Phone Number'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
