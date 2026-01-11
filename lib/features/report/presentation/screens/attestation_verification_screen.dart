/// Attestation Verification Screen
/// 
/// Screen for verifying blockchain attestations

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/attestation_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/attestation_event.dart';
import 'package:grampulse/features/report/presentation/bloc/attestation_state.dart';
import 'package:grampulse/features/report/presentation/widgets/attestation_widgets.dart';

class AttestationVerificationScreen extends StatefulWidget {
  final String? initialUid;

  const AttestationVerificationScreen({
    super.key,
    this.initialUid,
  });

  @override
  State<AttestationVerificationScreen> createState() =>
      _AttestationVerificationScreenState();
}

class _AttestationVerificationScreenState
    extends State<AttestationVerificationScreen> {
  final _uidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialUid != null) {
      _uidController.text = widget.initialUid!;
      // Auto-verify if UID is provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyAttestation();
      });
    }
  }

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  void _verifyAttestation() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AttestationBloc>().add(
            VerifyAttestation(_uidController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Attestation'),
        centerTitle: true,
      ),
      body: BlocBuilder<AttestationBloc, AttestationState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Blockchain Verification',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verify that a grievance resolution was recorded on the Optimism blockchain',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Input form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Attestation UID',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _uidController,
                        decoration: InputDecoration(
                          hintText: '0x...',
                          prefixIcon: const Icon(Icons.tag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        style: const TextStyle(fontFamily: 'monospace'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an attestation UID';
                          }
                          if (!value.startsWith('0x') || value.length != 66) {
                            return 'Invalid UID format (should be 0x + 64 hex chars)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: state is AttestationLoading
                            ? null
                            : _verifyAttestation,
                        icon: state is AttestationLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          state is AttestationLoading ? 'Verifying...' : 'Verify',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Results
                if (state is AttestationVerified) _buildVerificationResult(state),
                if (state is AttestationError) _buildErrorResult(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerificationResult(AttestationVerified state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: state.isValid
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: state.isValid ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.isValid ? Icons.check_circle : Icons.cancel,
                color: state.isValid ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                state.isValid ? 'Valid Attestation' : 'Invalid Attestation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: state.isValid ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (state.isValid) ...[
            const Divider(height: 32),
            _buildDetailRow('Grievance ID', state.grievanceId ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow('Village ID', state.villageId ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow('Resolver Role', state.resolverRole ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow('Attester', _truncate(state.attester ?? 'N/A')),
            if (state.ipfsHash != null && state.ipfsHash!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow('IPFS Proof', _truncate(state.ipfsHash!)),
            ],
            if (state.resolutionTimestamp != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Resolved At',
                DateTime.fromMillisecondsSinceEpoch(
                  state.resolutionTimestamp! * 1000,
                ).toString().split('.')[0],
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            Text(
              state.error ?? 'The attestation could not be verified',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorResult(AttestationError state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (state.details != null) ...[
            const SizedBox(height: 12),
            Text(
              state.details!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: value.startsWith('0x') ? 'monospace' : null,
                ),
          ),
        ),
      ],
    );
  }

  String _truncate(String value) {
    if (value.length <= 24) return value;
    return '${value.substring(0, 12)}...${value.substring(value.length - 10)}';
  }
}
