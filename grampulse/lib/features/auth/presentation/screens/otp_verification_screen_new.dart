import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_events_states.dart';
import '../blocs/auth_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  
  const OtpVerificationScreen({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus on OTP field when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length == 6) {
      context.read<AuthBloc>().add(VerifyOtpEvent(
        phone: widget.phone,
        otp: otp,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(RequestOtpEvent(phone: widget.phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Authentication successful!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to citizen home or profile setup
            context.go('/citizen-home');
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is OtpRequestedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP resent to ${widget.phone}'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify Your Phone',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to +91 ${widget.phone}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  
                  // OTP Input Field
                  TextFormField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '6-digit code',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (value.length == 6) {
                        // Auto-verify when 6 digits are entered
                        _verifyOtp();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _verifyOtp,
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Verify OTP'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Resend OTP
                  Center(
                    child: TextButton(
                      onPressed: state is AuthLoading ? null : _resendOtp,
                      child: const Text('Resend OTP'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info Text
                  Center(
                    child: Text(
                      'Check the console/terminal for the OTP code during development',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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
