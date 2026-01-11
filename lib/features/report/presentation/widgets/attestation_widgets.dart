/// Attestation Status Widget
/// 
/// Displays blockchain attestation status for a resolved grievance

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget to display attestation status badge
class AttestationStatusBadge extends StatelessWidget {
  final bool hasAttestation;
  final String? attestationUid;
  final VoidCallback? onTap;

  const AttestationStatusBadge({
    super.key,
    required this.hasAttestation,
    this.attestationUid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasAttestation
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasAttestation ? Colors.green : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasAttestation ? Icons.verified : Icons.pending_outlined,
              size: 16,
              color: hasAttestation ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              hasAttestation ? 'Verified on Chain' : 'Pending Verification',
              style: TextStyle(
                color: hasAttestation ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed attestation card widget
class AttestationDetailsCard extends StatelessWidget {
  final String attestationUid;
  final String? transactionHash;
  final String? explorerUrl;
  final String? ipfsCid;
  final String? ipfsUrl;
  final DateTime? timestamp;
  final String? attester;
  final VoidCallback? onVerify;

  const AttestationDetailsCard({
    super.key,
    required this.attestationUid,
    this.transactionHash,
    this.explorerUrl,
    this.ipfsCid,
    this.ipfsUrl,
    this.timestamp,
    this.attester,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blockchain Verified',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Resolution recorded on Optimism',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Attestation UID
            _buildInfoRow(
              context,
              'Attestation ID',
              _truncateUid(attestationUid),
              onCopy: () => _copyToClipboard(context, attestationUid),
            ),

            if (transactionHash != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Transaction',
                _truncateUid(transactionHash!),
                onCopy: () => _copyToClipboard(context, transactionHash!),
              ),
            ],

            if (timestamp != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Timestamp',
                _formatDate(timestamp!),
              ),
            ],

            if (ipfsCid != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Proof (IPFS)',
                _truncateUid(ipfsCid!),
                onCopy: () => _copyToClipboard(context, ipfsCid!),
                onTap: ipfsUrl != null ? () => _launchUrl(ipfsUrl!) : null,
              ),
            ],

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                if (explorerUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(explorerUrl!),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('View on Explorer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                if (onVerify != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onVerify,
                      icon: const Icon(Icons.verified, size: 18),
                      label: const Text('Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onCopy,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: onTap != null ? Colors.blue : null,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
            ),
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
      ],
    );
  }

  String _truncateUid(String uid) {
    if (uid.length <= 20) return uid;
    return '${uid.substring(0, 10)}...${uid.substring(uid.length - 8)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Compact attestation indicator for list items
class AttestationIndicator extends StatelessWidget {
  final bool isAttested;
  final bool isLoading;

  const AttestationIndicator({
    super.key,
    required this.isAttested,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    return Icon(
      isAttested ? Icons.verified : Icons.pending,
      size: 16,
      color: isAttested ? Colors.green : Colors.grey,
    );
  }
}

/// Widget for showing attestation creation progress
class AttestationProgressWidget extends StatelessWidget {
  final String status;
  final double? progress;

  const AttestationProgressWidget({
    super.key,
    required this.status,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                      ),
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}
