import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_log_bloc.dart';
import '../../shardeum_transaction_service.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

/// Real-Time Transaction Log Screen
/// Shows live blockchain transactions as they happen

class TransactionLogScreen extends StatelessWidget {
  const TransactionLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionLogBloc()..add(const LoadTransactionHistory()),
      child: const TransactionLogView(),
    );
  }
}

class TransactionLogView extends StatefulWidget {
  const TransactionLogView({super.key});

  @override
  State<TransactionLogView> createState() => _TransactionLogViewState();
}

class _TransactionLogViewState extends State<TransactionLogView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Log'),
        actions: [
          PopupMenuButton<TransactionStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            onSelected: (status) {
              context.read<TransactionLogBloc>().add(
                FilterTransactions(status: status),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Transactions'),
              ),
              const PopupMenuItem(
                value: TransactionStatus.confirmed,
                child: Text('✅ Confirmed'),
              ),
              const PopupMenuItem(
                value: TransactionStatus.pending,
                child: Text('⏳ Pending'),
              ),
              const PopupMenuItem(
                value: TransactionStatus.failed,
                child: Text('❌ Failed'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<TransactionLogBloc>().add(const RefreshTransactions());
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionLogBloc, TransactionLogState>(
        builder: (context, state) {
          if (state is TransactionLogLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLogError) {
            return _buildError(context, state.message, colorScheme);
          }

          if (state is TransactionLogLoaded) {
            return _buildContent(context, state, colorScheme);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTestTransactionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Test Transaction'),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TransactionLogLoaded state,
    ColorScheme colorScheme,
  ) {
    if (state.transactions.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return Column(
      children: [
        // Statistics Card
        _buildStatsCard(state.stats, colorScheme),
        
        // Transaction List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionLogBloc>().add(const RefreshTransactions());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final tx = state.transactions[index];
                return _buildTransactionCard(context, tx, colorScheme);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(TransactionStats stats, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Transaction Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  stats.totalTransactions.toString(),
                  Colors.blue,
                ),
                _buildStatItem(
                  'Confirmed',
                  stats.confirmedTransactions.toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'Pending',
                  stats.pendingTransactions.toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'Failed',
                  stats.failedTransactions.toString(),
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${stats.successRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Success Rate', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${stats.averageConfirmationTime.toStringAsFixed(1)}s',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Text('Avg. Time', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _formatGasCost(stats.totalGasCost),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const Text('Total Gas', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionLog tx,
    ColorScheme colorScheme,
  ) {
    final statusColor = _getStatusColor(tx.status);
    final statusIcon = _getStatusIcon(tx.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showTransactionDetails(context, tx),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.eventType.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Grievance: ${tx.grievanceId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      tx.status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Transaction Hash
              if (tx.txHash.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.tag,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _shortenHash(tx.txHash),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      onPressed: () => _openExplorer(tx.explorerUrl),
                      tooltip: 'View in Explorer',
                    ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(tx.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (tx.blockNumber != null)
                    Row(
                      children: [
                        Icon(
                          Icons.layers,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Block ${tx.blockNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  if (tx.gasUsed != null)
                    Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tx.gasUsed} gas',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // Duration
              if (tx.duration.inSeconds > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Confirmed in ${tx.duration.inSeconds}s',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Error Message
              if (tx.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tx.errorMessage!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a test transaction to get started',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error Loading Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<TransactionLogBloc>().add(const LoadTransactionHistory());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
      case TransactionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return Icons.check_circle;
      case TransactionStatus.pending:
        return Icons.hourglass_empty;
      case TransactionStatus.failed:
      case TransactionStatus.error:
        return Icons.cancel;
    }
  }

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  String _formatGasCost(BigInt gasCost) {
    final shm = EtherAmount.fromBigInt(EtherUnit.wei, gasCost);
    return '${shm.getValueInUnit(EtherUnit.ether).toStringAsFixed(6)} SHM';
  }

  void _openExplorer(String url) {
    // TODO: Implement URL launcher
    debugPrint('Opening: $url');
  }

  void _showTransactionDetails(BuildContext context, TransactionLog tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _TransactionDetailsSheet(
          tx: tx,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showTestTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send Test Transaction'),
        content: const Text(
          'This will send a real transaction to the Shardeum network. '
          'A small amount of gas will be consumed.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TransactionLogBloc>().add(const SendTestTransaction());
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// Transaction Details Bottom Sheet
class _TransactionDetailsSheet extends StatelessWidget {
  final TransactionLog tx;
  final ScrollController scrollController;

  const _TransactionDetailsSheet({
    required this.tx,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Transaction Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Event Type', tx.eventType),
          _buildDetailRow('Grievance ID', tx.grievanceId),
          _buildDetailRow('Village ID', tx.villageId),
          if (tx.txHash.isNotEmpty) _buildDetailRow('Transaction Hash', tx.txHash),
          if (tx.blockNumber != null) _buildDetailRow('Block Number', '${tx.blockNumber}'),
          if (tx.gasUsed != null) _buildDetailRow('Gas Used', '${tx.gasUsed}'),
          _buildDetailRow('Status', tx.status.name.toUpperCase()),
          _buildDetailRow('Timestamp', DateFormat('yyyy-MM-dd HH:mm:ss').format(tx.timestamp)),
          if (tx.confirmedAt != null)
            _buildDetailRow('Confirmed At', DateFormat('yyyy-MM-dd HH:mm:ss').format(tx.confirmedAt!)),
          if (tx.duration.inSeconds > 0)
            _buildDetailRow('Confirmation Time', '${tx.duration.inSeconds} seconds'),
          const SizedBox(height: 16),
          const Text('Metadata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tx.metadata.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}
