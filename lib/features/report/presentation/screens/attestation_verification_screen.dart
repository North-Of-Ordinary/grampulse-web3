/// Attestation Verification Screen - Verify blockchain proofs
/// Part of PHASE 5: Web3 Governance & Transparency

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/attestation_bloc.dart';
import 'package:grampulse/core/theme/color_schemes.dart';

class AttestationVerificationScreen extends StatefulWidget {
  final String? initialUid;

  const AttestationVerificationScreen({super.key, this.initialUid});

  @override
  State<AttestationVerificationScreen> createState() => _AttestationVerificationScreenState();
}

class _AttestationVerificationScreenState extends State<AttestationVerificationScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialUid != null && widget.initialUid!.isNotEmpty) {
      _searchController.text = widget.initialUid!;
      context.read<AttestationBloc>().add(VerifyAttestation(widget.initialUid!));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkSurfaces.level0 : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? DarkSurfaces.level1 : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Verify Attestation',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(colorScheme, isDark),

          // Content
          Expanded(
            child: BlocBuilder<AttestationBloc, AttestationState>(
              builder: (context, state) {
                if (state is AttestationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AttestationError) {
                  return _buildErrorView(state.message, colorScheme);
                }

                if (state is AttestationNotFound) {
                  return _buildNotFoundView(state.uid, colorScheme, isDark);
                }

                if (state is AttestationVerified) {
                  return _buildVerifiedView(state.attestation, colorScheme, isDark);
                }

                return _buildInitialView(colorScheme, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkSurfaces.level1 : colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Enter attestation UID or transaction hash',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
              ),
            ],
          ),
          filled: true,
          fillColor: isDark ? DarkSurfaces.level2 : colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() {}),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<AttestationBloc>().add(VerifyAttestation(value));
          }
        },
      ),
    );
  }

  Widget _buildInitialView(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Verify Blockchain Attestation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter an attestation UID or scan a QR code to verify the authenticity of a blockchain record.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _scanQRCode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text('Verification Failed', style: TextStyle(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildNotFoundView(String uid, ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 56,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Attestation Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No blockchain record found for:\n"$uid"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Please verify the UID and try again.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedView(AttestationDetails attestation, ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Verified Badge
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade500,
                  Colors.green.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VERIFIED ON BLOCKCHAIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This attestation is authentic',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Attestation Details
          _buildDetailCard(
            'Attestation Details',
            [
              _buildDetailRow('UID', attestation.uid, colorScheme, canCopy: true),
              _buildDetailRow('Issue ID', attestation.issueId, colorScheme),
              _buildDetailRow('Type', attestation.issueType, colorScheme),
              _buildDetailRow('Status', attestation.status, colorScheme),
              _buildDetailRow('Timestamp', _formatDate(attestation.timestamp), colorScheme),
            ],
            colorScheme,
            isDark,
          ),
          const SizedBox(height: 16),

          // Blockchain Details
          _buildDetailCard(
            'Blockchain Record',
            [
              _buildDetailRow('Transaction', _truncateHash(attestation.transactionHash), colorScheme, canCopy: true),
              _buildDetailRow('Block', attestation.blockNumber, colorScheme),
              _buildDetailRow('Network', 'Shardeum Sphinx', colorScheme),
            ],
            colorScheme,
            isDark,
          ),
          const SizedBox(height: 16),

          // Parties Involved
          _buildDetailCard(
            'Parties Involved',
            [
              _buildDetailRow('Reporter', _truncateHash(attestation.reporter), colorScheme, canCopy: true),
              _buildDetailRow('Resolver', _truncateHash(attestation.resolver), colorScheme, canCopy: true),
            ],
            colorScheme,
            isDark,
          ),
          const SizedBox(height: 16),

          // Metadata
          if (attestation.metadata != null && attestation.metadata!.isNotEmpty)
            _buildDetailCard(
              'Additional Information',
              attestation.metadata!.entries.map((e) => 
                _buildDetailRow(e.key, e.value.toString(), colorScheme)
              ).toList(),
              colorScheme,
              isDark,
            ),
          const SizedBox(height: 24),

          // View on Explorer Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Open blockchain explorer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening blockchain explorer...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on Blockchain Explorer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    List<Widget> children,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkSurfaces.level2 : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (canCopy)
            IconButton(
              icon: Icon(Icons.copy, size: 16, color: colorScheme.primary),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  String _truncateHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _scanQRCode() {
    // TODO: Implement QR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
