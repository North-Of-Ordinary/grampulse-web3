import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shardeum_network_config.dart';

/// Shardeum Transaction Service
/// Handles REAL blockchain transactions with signing and logging

class ShardeumTransactionService {
  // Singleton pattern
  static final ShardeumTransactionService _instance =
      ShardeumTransactionService._internal();
  factory ShardeumTransactionService() => _instance;
  ShardeumTransactionService._internal();

  Web3Client? _client;
  EthPrivateKey? _credentials;
  bool _isInitialized = false;

  final List<TransactionLog> _transactionHistory = [];
  final List<Function(TransactionLog)> _listeners = [];

  // ═══════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════

  String? _currentRpcUrl;

  Future<bool> initialize() async {
    if (!ShardeumNetworkConfig.isEnabled) {
      _log('❌ Shardeum is disabled in config');
      return false;
    }

    if (!ShardeumNetworkConfig.enableEventLogging) {
      _log('⚠️ Event logging disabled - read-only mode');
      return false;
    }

    try {
      // Try to connect to RPC with fallbacks
      final rpcUrl = await _findWorkingRpc();
      if (rpcUrl == null) {
        _log('❌ No working RPC endpoint found');
        return false;
      }

      _currentRpcUrl = rpcUrl;
      _client = Web3Client(rpcUrl, http.Client());
      _log('✅ Connected to RPC: $rpcUrl');

      // Load private key if available
      final privateKey = dotenv.env['SHARDEUM_PRIVATE_KEY'];
      if (privateKey != null &&
          privateKey.isNotEmpty &&
          privateKey != 'your-private-key-here-without-0x-prefix') {
        _credentials = EthPrivateKey.fromHex(privateKey);
        final address = _credentials!.address;
        _log('✅ Wallet initialized: ${address.hex}');
        _isInitialized = true;
        return true;
      } else {
        _log('⚠️ No private key configured - read-only mode');
        return false;
      }
    } catch (e) {
      _log('❌ Initialization failed: $e');
      return false;
    }
  }

  /// Try each RPC URL until we find one that works
  Future<String?> _findWorkingRpc() async {
    final urlsToTry =
        [
          ShardeumNetworkConfig.rpcUrl,
          ...ShardeumNetworkConfig.fallbackRpcUrls,
        ].toSet().toList(); // Remove duplicates

    for (final url in urlsToTry) {
      _log('🔗 Trying RPC: $url');
      try {
        final testClient = Web3Client(url, http.Client());
        // Try to get chain ID to verify connection
        final chainId = await testClient.getChainId().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout'),
        );
        testClient.dispose();

        if (chainId.toInt() == ShardeumNetworkConfig.chainId) {
          _log('✅ RPC working: $url (Chain ID: $chainId)');
          return url;
        } else {
          _log('⚠️ Wrong chain ID at $url: $chainId');
        }
      } catch (e) {
        _log('❌ RPC failed: $url - $e');
      }
    }

    return null;
  }

  bool get isReady => _isInitialized && _client != null && _credentials != null;
  EthereumAddress? get walletAddress => _credentials?.address;
  String? get currentRpcUrl => _currentRpcUrl;

  // ═══════════════════════════════════════════════════════════════════
  // REAL TRANSACTION EXECUTION
  // ═══════════════════════════════════════════════════════════════════

  /// Send a real transaction to log a civic event
  Future<TransactionResult> logCivicEvent({
    required String eventType,
    required String villageId,
    required String grievanceId,
    required Map<String, dynamic> metadata,
  }) async {
    if (!isReady) {
      return TransactionResult.error(
        'Service not initialized or no wallet configured',
      );
    }

    final startTime = DateTime.now();
    _log('📤 Starting transaction: $eventType for $grievanceId');

    try {
      // Prepare event data
      final eventData = {
        'type': eventType,
        'villageId': villageId,
        'grievanceId': grievanceId,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata,
      };

      // Convert to hex data
      final dataString = jsonEncode(eventData);
      final dataBytes = utf8.encode(dataString);
      final hexData =
          '0x${dataBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      // Get current gas price
      final gasPrice = await _client!.getGasPrice();
      final gasPriceValue = gasPrice.getInWei;
      final adjustedGasPrice = EtherAmount.inWei(
        gasPriceValue * BigInt.from(12) ~/ BigInt.from(10),
      ); // 1.2x

      // Get nonce
      final nonce = await _client!.getTransactionCount(
        _credentials!.address,
        atBlock: const BlockNum.pending(),
      );

      _log(
        '⛽ Gas price: ${EtherAmount.fromBigInt(EtherUnit.wei, adjustedGasPrice.getInWei).getValueInUnit(EtherUnit.gwei)} Gwei',
      );
      _log('🔢 Nonce: $nonce');

      // Convert data to Uint8List
      final dataUint8List = Uint8List.fromList(hexToBytes(hexData));

      // Create transaction
      final transaction = Transaction(
        to: _credentials!.address, // Send to self with data payload
        gasPrice: adjustedGasPrice,
        maxGas: 100000,
        nonce: nonce,
        value: EtherAmount.zero(),
        data: dataUint8List,
      );

      // Sign and send
      _log('✍️ Signing transaction...');
      final txHash = await _client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: ShardeumNetworkConfig.chainId,
      );

      _log('✅ Transaction sent: $txHash');

      // Wait for confirmation
      _log('⏳ Waiting for confirmation...');
      final receipt = await _waitForReceipt(txHash, maxWaitSeconds: 60);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      if (receipt != null && receipt.status == true) {
        _log(
          '✅ Transaction confirmed in block ${receipt.blockNumber.blockNum}',
        );

        final txLog = TransactionLog(
          txHash: txHash,
          eventType: eventType,
          villageId: villageId,
          grievanceId: grievanceId,
          metadata: metadata,
          timestamp: startTime,
          confirmedAt: endTime,
          status: TransactionStatus.confirmed,
          blockNumber: receipt.blockNumber.blockNum,
          gasUsed: (receipt.gasUsed ?? BigInt.zero).toInt(),
          gasCost: (receipt.gasUsed ?? BigInt.zero) * adjustedGasPrice.getInWei,
          duration: duration,
        );

        _addToHistory(txLog);

        return TransactionResult.success(
          txHash: txHash,
          blockNumber: receipt.blockNumber.blockNum,
          gasUsed: (receipt.gasUsed ?? BigInt.zero).toInt(),
          log: txLog,
        );
      } else {
        _log('❌ Transaction failed or reverted');

        final txLog = TransactionLog(
          txHash: txHash,
          eventType: eventType,
          villageId: villageId,
          grievanceId: grievanceId,
          metadata: metadata,
          timestamp: startTime,
          status: TransactionStatus.failed,
          duration: duration,
        );

        _addToHistory(txLog);

        return TransactionResult.error('Transaction failed or reverted');
      }
    } catch (e) {
      _log('❌ Transaction error: $e');

      final txLog = TransactionLog(
        txHash: '',
        eventType: eventType,
        villageId: villageId,
        grievanceId: grievanceId,
        metadata: metadata,
        timestamp: startTime,
        status: TransactionStatus.error,
        errorMessage: e.toString(),
        duration: Duration.zero,
      );

      _addToHistory(txLog);

      return TransactionResult.error(e.toString());
    }
  }

  /// Wait for transaction receipt with timeout
  Future<TransactionReceipt?> _waitForReceipt(
    String txHash, {
    int maxWaitSeconds = 60,
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime).inSeconds < maxWaitSeconds) {
      try {
        final receipt = await _client!.getTransactionReceipt(txHash);
        if (receipt != null) {
          return receipt;
        }
      } catch (e) {
        // Transaction not yet mined
      }

      await Future.delayed(const Duration(seconds: 2));
      _log(
        '⏳ Still waiting... (${DateTime.now().difference(startTime).inSeconds}s)',
      );
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // TRANSACTION HISTORY & MONITORING
  // ═══════════════════════════════════════════════════════════════════

  List<TransactionLog> get transactionHistory =>
      List.unmodifiable(_transactionHistory);

  List<TransactionLog> getRecentTransactions({int limit = 20}) {
    return _transactionHistory.take(limit).toList();
  }

  List<TransactionLog> getTransactionsByStatus(TransactionStatus status) {
    return _transactionHistory.where((tx) => tx.status == status).toList();
  }

  TransactionLog? getTransactionByHash(String txHash) {
    try {
      return _transactionHistory.firstWhere((tx) => tx.txHash == txHash);
    } catch (e) {
      return null;
    }
  }

  void _addToHistory(TransactionLog log) {
    _transactionHistory.insert(0, log); // Add to beginning
    _notifyListeners(log);
  }

  // ═══════════════════════════════════════════════════════════════════
  // REAL-TIME LISTENERS
  // ═══════════════════════════════════════════════════════════════════

  void addTransactionListener(Function(TransactionLog) listener) {
    _listeners.add(listener);
  }

  void removeTransactionListener(Function(TransactionLog) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(TransactionLog log) {
    for (var listener in _listeners) {
      try {
        listener(log);
      } catch (e) {
        _log('❌ Listener error: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // WALLET QUERIES
  // ═══════════════════════════════════════════════════════════════════

  Future<BigInt> getBalance([EthereumAddress? address]) async {
    if (_client == null) return BigInt.zero;

    try {
      final addr = address ?? _credentials?.address;
      if (addr == null) return BigInt.zero;

      final balance = await _client!.getBalance(addr);
      return balance.getInWei;
    } catch (e) {
      _log('❌ Failed to get balance: $e');
      return BigInt.zero;
    }
  }

  Future<int> getTransactionCount([EthereumAddress? address]) async {
    if (_client == null) return 0;

    try {
      final addr = address ?? _credentials?.address;
      if (addr == null) return 0;

      return await _client!.getTransactionCount(addr);
    } catch (e) {
      _log('❌ Failed to get transaction count: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATISTICS
  // ═══════════════════════════════════════════════════════════════════

  TransactionStats getStats() {
    final total = _transactionHistory.length;
    final confirmed =
        _transactionHistory
            .where((tx) => tx.status == TransactionStatus.confirmed)
            .length;
    final pending =
        _transactionHistory
            .where((tx) => tx.status == TransactionStatus.pending)
            .length;
    final failed =
        _transactionHistory
            .where((tx) => tx.status == TransactionStatus.failed)
            .length;

    final totalGasCost = _transactionHistory
        .where((tx) => tx.status == TransactionStatus.confirmed)
        .fold<BigInt>(BigInt.zero, (sum, tx) => sum + tx.gasCost);

    final avgDuration =
        _transactionHistory.isNotEmpty
            ? _transactionHistory
                    .where((tx) => tx.duration.inSeconds > 0)
                    .map((tx) => tx.duration.inSeconds)
                    .fold<int>(0, (sum, d) => sum + d) /
                _transactionHistory
                    .where((tx) => tx.duration.inSeconds > 0)
                    .length
            : 0.0;

    return TransactionStats(
      totalTransactions: total,
      confirmedTransactions: confirmed,
      pendingTransactions: pending,
      failedTransactions: failed,
      totalGasCost: totalGasCost,
      averageConfirmationTime: avgDuration,
    );
  }

  void _log(String message) {
    debugPrint('[ShardeumTx] $message');
  }

  void dispose() {
    _client?.dispose();
    _listeners.clear();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════

enum TransactionStatus { pending, confirmed, failed, error }

class TransactionLog {
  final String txHash;
  final String eventType;
  final String villageId;
  final String grievanceId;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final DateTime? confirmedAt;
  final TransactionStatus status;
  final int? blockNumber;
  final int? gasUsed;
  final BigInt gasCost;
  final Duration duration;
  final String? errorMessage;

  TransactionLog({
    required this.txHash,
    required this.eventType,
    required this.villageId,
    required this.grievanceId,
    required this.metadata,
    required this.timestamp,
    this.confirmedAt,
    required this.status,
    this.blockNumber,
    this.gasUsed,
    BigInt? gasCost,
    required this.duration,
    this.errorMessage,
  }) : gasCost = gasCost ?? BigInt.zero;

  String get explorerUrl =>
      'https://explorer-atomium.shardeum.org/transaction/$txHash';

  Map<String, dynamic> toJson() => {
    'txHash': txHash,
    'eventType': eventType,
    'villageId': villageId,
    'grievanceId': grievanceId,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
    'confirmedAt': confirmedAt?.toIso8601String(),
    'status': status.name,
    'blockNumber': blockNumber,
    'gasUsed': gasUsed,
    'gasCost': gasCost.toString(),
    'duration': duration.inSeconds,
    'errorMessage': errorMessage,
  };
}

class TransactionResult {
  final bool success;
  final String? txHash;
  final int? blockNumber;
  final int? gasUsed;
  final String? errorMessage;
  final TransactionLog? log;

  TransactionResult._({
    required this.success,
    this.txHash,
    this.blockNumber,
    this.gasUsed,
    this.errorMessage,
    this.log,
  });

  factory TransactionResult.success({
    required String txHash,
    required int blockNumber,
    required int gasUsed,
    required TransactionLog log,
  }) => TransactionResult._(
    success: true,
    txHash: txHash,
    blockNumber: blockNumber,
    gasUsed: gasUsed,
    log: log,
  );

  factory TransactionResult.error(String message) =>
      TransactionResult._(success: false, errorMessage: message);
}

class TransactionStats {
  final int totalTransactions;
  final int confirmedTransactions;
  final int pendingTransactions;
  final int failedTransactions;
  final BigInt totalGasCost;
  final double averageConfirmationTime;

  TransactionStats({
    required this.totalTransactions,
    required this.confirmedTransactions,
    required this.pendingTransactions,
    required this.failedTransactions,
    required this.totalGasCost,
    required this.averageConfirmationTime,
  });

  double get successRate =>
      totalTransactions > 0
          ? confirmedTransactions / totalTransactions * 100
          : 0.0;
}

// Helper function
List<int> hexToBytes(String hex) {
  hex = hex.replaceFirst('0x', '');
  final result = <int>[];
  for (int i = 0; i < hex.length; i += 2) {
    result.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return result;
}
