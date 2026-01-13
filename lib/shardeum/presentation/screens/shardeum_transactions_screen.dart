import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shardeum_transaction_service.dart';
import '../../shardeum_network_config.dart';

/// Real-Time Shardeum Transaction Dashboard
/// 
/// Shows live blockchain transactions, wallet balance, and allows
/// sending test transactions to verify the connection is working.

class ShardeumTransactionsScreen extends StatefulWidget {
  const ShardeumTransactionsScreen({super.key});

  @override
  State<ShardeumTransactionsScreen> createState() => _ShardeumTransactionsScreenState();
}

class _ShardeumTransactionsScreenState extends State<ShardeumTransactionsScreen> {
  final ShardeumTransactionService _txService = ShardeumTransactionService();
  
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _walletAddress;
  BigInt _balance = BigInt.zero;
  int _transactionCount = 0;
  List<TransactionLog> _transactions = [];
  TransactionStats? _stats;
  String? _error;
  bool _isSendingTestTx = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _txService.addTransactionListener(_onNewTransaction);
  }

  @override
  void dispose() {
    _txService.removeTransactionListener(_onNewTransaction);
    super.dispose();
  }

  void _onNewTransaction(TransactionLog log) {
    if (mounted) {
      setState(() {
        _transactions = _txService.getRecentTransactions(limit: 50);
        _stats = _txService.getStats();
      });
      _loadWalletInfo();
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final initialized = await _txService.initialize();
      
      if (initialized) {
        _walletAddress = _txService.walletAddress?.hex;
        await _loadWalletInfo();
        _transactions = _txService.getRecentTransactions(limit: 50);
        _stats = _txService.getStats();
      }
      
      setState(() {
        _isInitialized = initialized;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWalletInfo() async {
    try {
      final balance = await _txService.getBalance();
      final txCount = await _txService.getTransactionCount();
      
      if (mounted) {
        setState(() {
          _balance = balance;
          _transactionCount = txCount;
        });
      }
    } catch (e) {
      debugPrint('Failed to load wallet info: $e');
    }
  }

  Future<void> _sendTestTransaction() async {
    if (_isSendingTestTx || !_isInitialized) return;

    setState(() {
      _isSendingTestTx = true;
    });

    try {
      final result = await _txService.logCivicEvent(
        eventType: 'TEST_TRANSACTION',
        villageId: 'TEST-VILLAGE-001',
        grievanceId: 'GRV-TEST-${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          'test': true,
          'source': 'grampulse_app',
          'platform': 'flutter',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success 
                  ? '✅ Transaction confirmed! Hash: ${result.txHash?.substring(0, 10)}...'
                  : '❌ Transaction failed: ${result.errorMessage}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: result.success ? SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                if (result.log != null) {
                  _openExplorer(result.log!.explorerUrl);
                }
              },
            ) : null,
          ),
        );

        // Refresh data
        _transactions = _txService.getRecentTransactions(limit: 50);
        _stats = _txService.getStats();
        await _loadWalletInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingTestTx = false;
        });
      }
    }
  }

  Future<void> _openExplorer(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shardeum Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _initialize,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(colorScheme),
      floatingActionButton: _isInitialized ? FloatingActionButton.extended(
        onPressed: _isSendingTestTx ? null : _sendTestTransaction,
        icon: _isSendingTestTx 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send),
        label: Text(_isSendingTestTx ? 'Sending...' : 'Send Test Tx'),
        backgroundColor: _isSendingTestTx ? Colors.grey : colorScheme.primary,
      ) : null,
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_error != null) {
      return _buildErrorState(colorScheme);
    }

    if (!_isInitialized) {
      return _buildNotInitializedState(colorScheme);
    }

    return RefreshIndicator(
      onRefresh: _initialize,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWalletCard(colorScheme),
            const SizedBox(height: 16),
            _buildStatsCard(colorScheme),
            const SizedBox(height: 16),
            _buildNetworkInfoCard(colorScheme),
            const SizedBox(height: 16),
            _buildTransactionsList(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _initialize,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotInitializedState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 64, color: colorScheme.tertiary),
            const SizedBox(height: 16),
            const Text(
              'Shardeum Not Configured',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'To enable real blockchain transactions:\n\n'
              '1. Set SHARDEUM_ENABLED=true in .env\n'
              '2. Set SHARDEUM_EVENT_LOGGING=true\n'
              '3. Add your SHARDEUM_PRIVATE_KEY\n'
              '4. Get test SHM from faucet',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                _openExplorer('https://docs.shardeum.org/faucet/claim');
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Get Test Tokens'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(ColorScheme colorScheme) {
    final balanceInSHM = _balance / BigInt.from(10).pow(18);
    
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Wallet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Connected', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _walletAddress ?? 'Unknown',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: 16, color: colorScheme.onPrimaryContainer),
                            onPressed: () {
                              if (_walletAddress != null) {
                                Clipboard.setData(ClipboardData(text: _walletAddress!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Address copied!')),
                                );
                              }
                            },
                            tooltip: 'Copy address',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: 12),
                      ),
                      Text(
                        '${balanceInSHM.toStringAsFixed(4)} SHM',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: 12),
                      ),
                      Text(
                        '$_transactionCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ColorScheme colorScheme) {
    final stats = _stats ?? TransactionStats(
      totalTransactions: 0,
      confirmedTransactions: 0,
      pendingTransactions: 0,
      failedTransactions: 0,
      totalGasCost: BigInt.zero,
      averageConfirmationTime: 0,
    );

    return Card(
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
                  'Session Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Total', stats.totalTransactions.toString(), Colors.blue, Icons.receipt_long),
                _buildStatItem('Confirmed', stats.confirmedTransactions.toString(), Colors.green, Icons.check_circle),
                _buildStatItem('Pending', stats.pendingTransactions.toString(), Colors.orange, Icons.pending),
                _buildStatItem('Failed', stats.failedTransactions.toString(), Colors.red, Icons.error),
              ],
            ),
            if (stats.confirmedTransactions > 0) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Success Rate',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${stats.successRate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg Confirmation Time',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${stats.averageConfirmationTime.toStringAsFixed(1)}s',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub, color: colorScheme.secondary),
                const SizedBox(width: 8),
                const Text(
                  'Network Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Network', ShardeumNetworkConfig.networkName),
            _buildInfoRow('Chain ID', ShardeumNetworkConfig.chainId.toString()),
            _buildInfoRow('Currency', ShardeumNetworkConfig.currencySymbol),
            _buildInfoRow('RPC', ShardeumNetworkConfig.rpcUrl, isMonospace: true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openExplorer(ShardeumNetworkConfig.explorerUrl),
                icon: const Icon(Icons.explore),
                label: const Text('View on Explorer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: isMonospace ? 11 : null,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(ColorScheme colorScheme) {
    if (_transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: colorScheme.outline),
              const SizedBox(height: 16),
              const Text('No transactions yet'),
              const SizedBox(height: 8),
              Text(
                'Send a test transaction to see it here',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Transaction History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_transactions.length} transactions',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return _buildTransactionTile(tx, colorScheme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionLog tx, ColorScheme colorScheme) {
    final statusColor = switch (tx.status) {
      TransactionStatus.confirmed => Colors.green,
      TransactionStatus.pending => Colors.orange,
      TransactionStatus.failed => Colors.red,
      TransactionStatus.error => Colors.red,
    };

    final statusIcon = switch (tx.status) {
      TransactionStatus.confirmed => Icons.check_circle,
      TransactionStatus.pending => Icons.pending,
      TransactionStatus.failed => Icons.cancel,
      TransactionStatus.error => Icons.error,
    };

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(statusIcon, color: statusColor, size: 20),
      ),
      title: Text(
        tx.eventType,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tx.txHash.isNotEmpty 
                ? '${tx.txHash.substring(0, 10)}...${tx.txHash.substring(tx.txHash.length - 8)}'
                : 'No hash',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
          if (tx.blockNumber != null)
            Text('Block: ${tx.blockNumber}', style: const TextStyle(fontSize: 11)),
          Text(
            '${_formatTimestamp(tx.timestamp)} • ${tx.duration.inSeconds}s',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new, size: 20),
        onPressed: tx.txHash.isNotEmpty ? () => _openExplorer(tx.explorerUrl) : null,
        tooltip: 'View on Explorer',
      ),
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
