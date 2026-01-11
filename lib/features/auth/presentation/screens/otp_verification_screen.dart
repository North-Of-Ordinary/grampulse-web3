import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/auth/presentation/bloc/otp_verification_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6, 
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, 
    (_) => FocusNode(),
  );

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    
    // Start countdown timer
    Future.microtask(() => 
      context.read<OtpVerificationBloc>().add(const StartTimerEvent())
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
      ),
      body: BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            context.go('/profile-setup');
          } else if (state is OtpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'OTP sent to',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '+91 ${widget.phoneNumber}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => _buildOtpDigitField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        nextFocusNode: index < 5 ? _focusNodes[index + 1] : null,
                        previousFocusNode: index > 0 ? _focusNodes[index - 1] : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  _buildResendSection(state),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _otp.length == 6 && state is! OtpSubmitting
                          ? () {
                              context.read<OtpVerificationBloc>().add(
                                    VerifyOtpEvent(
                                      otp: _otp,
                                      phoneNumber: widget.phoneNumber,
                                    ),
                                  );
                            }
                          : null,
                      child: state is OtpSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Verify & Continue'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpDigitField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    FocusNode? previousFocusNode,
  }) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && nextFocusNode != null) {
            nextFocusNode.requestFocus();
          } else if (value.isEmpty && previousFocusNode != null) {
            previousFocusNode.requestFocus();
          }
          
          // Auto verify if all digits are filled
          if (_otp.length == 6) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Widget _buildResendSection(OtpVerificationState state) {
    if (state is OtpTimerRunning) {
      return Text(
        'Resend OTP in ${state.timeRemaining} seconds',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    } else if (state is OtpResending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            'Sending...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    } else if (state is OtpTimerCompleted || state is OtpInitial) {
      return TextButton(
        onPressed: () {
          context.read<OtpVerificationBloc>().add(
                ResendOtpEvent(phoneNumber: widget.phoneNumber),
              );
        },
        child: const Text('Resend OTP'),
      );
    } else {
      return const SizedBox();
    }
  }
}
