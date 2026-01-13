import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shardeum_network_config.dart';

/// Shardeum Service - Read-Only Provider
/// 
/// Architecture Role: Provides READ-ONLY access to Shardeum network.
/// This service is designed for monitoring and event verification only.
/// 
/// CRITICAL: This service DOES NOT execute transactions.
/// All write operations must go through Optimism (canonical trust layer).
/// 
/// "Shardeum scales events, Optimism certifies outcomes"

class ShardeumService {
  // ═══════════════════════════════════════════════════════════════════
  // SINGLETON PATTERN
  // ═══════════════════════════════════════════════════════════════════
  
  static final ShardeumService _instance = ShardeumService._internal();
  factory ShardeumService() => _instance;
  ShardeumService._internal();

  // ═══════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════
  
  bool _isInitialized = false;
  DateTime? _lastConnectionCheck;
  ShardeumChainInfo? _cachedChainInfo;

  // ═══════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════
  
  /// Initialize the Shardeum service
  /// Returns false if Shardeum is disabled in configuration
  Future<bool> initialize() async {
    if (!ShardeumNetworkConfig.isEnabled) {
      debugPrint('[Shardeum] Service disabled by configuration');
      return false;
    }

    if (!ShardeumNetworkConfig.isValidConfiguration) {
      debugPrint('[Shardeum] Invalid configuration detected');
      return false;
    }

    _isInitialized = true;
    debugPrint('[Shardeum] Service initialized (read-only mode)');
    return true;
  }

  /// Check if service is ready for use
  bool get isReady => _isInitialized && ShardeumNetworkConfig.isEnabled;

  // ═══════════════════════════════════════════════════════════════════
  // CONNECTION STATUS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Check if connected to Shardeum network
  /// Returns connection status with optional caching
  Future<ShardeumConnectionStatus> isConnected({
    bool forceCheck = false,
    Duration cacheDuration = const Duration(seconds: 30),
  }) async {
    // Return disabled status if not enabled
    if (!ShardeumNetworkConfig.isEnabled) {
      return ShardeumConnectionStatus(
        isConnected: false,
        status: ConnectionState.disabled,
        message: 'Shardeum integration is disabled',
        checkedAt: DateTime.now(),
      );
    }

    // Use cached result if available and not forcing check
    if (!forceCheck && _lastConnectionCheck != null) {
      final elapsed = DateTime.now().difference(_lastConnectionCheck!);
      if (elapsed < cacheDuration) {
        return ShardeumConnectionStatus(
          isConnected: true,
          status: ConnectionState.connected,
          message: 'Connected (cached)',
          checkedAt: _lastConnectionCheck!,
        );
      }
    }

    try {
      // Make a simple JSON-RPC call to check connectivity
      final response = await _makeRpcCall('eth_chainId', []);
      
      if (response != null) {
        _lastConnectionCheck = DateTime.now();
        return ShardeumConnectionStatus(
          isConnected: true,
          status: ConnectionState.connected,
          message: 'Connected to ${ShardeumNetworkConfig.networkName}',
          checkedAt: _lastConnectionCheck!,
          chainId: _parseChainId(response),
        );
      }
    } catch (e) {
      debugPrint('[Shardeum] Connection check failed: $e');
    }

    return ShardeumConnectionStatus(
      isConnected: false,
      status: ConnectionState.disconnected,
      message: 'Unable to connect to Shardeum network',
      checkedAt: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHAIN INFORMATION
  // ═══════════════════════════════════════════════════════════════════
  
  /// Get comprehensive chain information
  /// Includes network details, block info, and architecture role
  Future<ShardeumChainInfo> getChainInfo({bool useCache = true}) async {
    // Return cached if available
    if (useCache && _cachedChainInfo != null) {
      return _cachedChainInfo!;
    }

    // Return disabled info if not enabled
    if (!ShardeumNetworkConfig.isEnabled) {
      return ShardeumChainInfo(
        networkName: ShardeumNetworkConfig.networkName,
        chainId: ShardeumNetworkConfig.testnetChainId,
        isEnabled: false,
        architecturalRole: 'Disabled - Optimism is primary chain',
        capabilities: [],
      );
    }

    try {
      // Fetch chain ID
      final chainIdResponse = await _makeRpcCall('eth_chainId', []);
      final chainId = _parseChainId(chainIdResponse);

      // Fetch latest block number
      final blockResponse = await _makeRpcCall('eth_blockNumber', []);
      final blockNumber = _parseHexInt(blockResponse);

      // Fetch gas price (for informational purposes only)
      final gasPriceResponse = await _makeRpcCall('eth_gasPrice', []);
      final gasPrice = _parseHexInt(gasPriceResponse);

      _cachedChainInfo = ShardeumChainInfo(
        networkName: ShardeumNetworkConfig.networkName,
        chainId: chainId,
        isEnabled: true,
        latestBlock: blockNumber,
        gasPrice: gasPrice,
        rpcUrl: ShardeumNetworkConfig.rpcUrl,
        explorerUrl: ShardeumNetworkConfig.explorerUrl,
        currencySymbol: ShardeumNetworkConfig.currencySymbol,
        architecturalRole: 'High-throughput civic event layer',
        capabilities: ShardeumNetworkConfig.shardeumHandles,
        limitations: ShardeumNetworkConfig.shardeumDoesNotHandle,
        fetchedAt: DateTime.now(),
      );

      return _cachedChainInfo!;
    } catch (e) {
      debugPrint('[Shardeum] Failed to fetch chain info: $e');
      
      // Return basic info on error
      return ShardeumChainInfo(
        networkName: ShardeumNetworkConfig.networkName,
        chainId: ShardeumNetworkConfig.testnetChainId,
        isEnabled: true,
        architecturalRole: 'High-throughput civic event layer (offline)',
        capabilities: ShardeumNetworkConfig.shardeumHandles,
        error: e.toString(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ARCHITECTURE HELPERS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Get the architectural explanation for this integration
  String getArchitectureExplanation() {
    return '''
╔═══════════════════════════════════════════════════════════════════════╗
║              GRAMPULSE MULTI-CHAIN ARCHITECTURE                       ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  "Shardeum scales events, Optimism certifies outcomes"                ║
║                                                                       ║
║  ┌──────────────┐                                                     ║
║  │ SHARDEUM     │  → High-throughput civic event logging              ║
║  │ (This Layer) │  → Low-cost activity tracking                       ║
║  │              │  → Scalability buffer                               ║
║  └──────┬───────┘                                                     ║
║         │ Events aggregated & verified                                ║
║         ▼                                                             ║
║  ┌──────────────┐                                                     ║
║  │ OPTIMISM     │  → Canonical trust layer                            ║
║  │ (Primary)    │  → Final attestations                               ║
║  │              │  → Proof-of-Resolution                              ║
║  └──────────────┘                                                     ║
║                                                                       ║
║  STATUS: ${ShardeumNetworkConfig.isEnabled ? 'ENABLED' : 'DISABLED (Optimism-only mode)'}
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
''';
  }

  /// Check if an action should use Shardeum or Optimism
  ChainRecommendation getChainForAction(CivicActionType actionType) {
    // Critical actions ALWAYS go to Optimism
    if (_isCriticalAction(actionType)) {
      return ChainRecommendation(
        recommendedChain: 'Optimism',
        reason: 'Critical governance actions require canonical trust layer',
        shardeumSuitable: false,
      );
    }

    // Non-critical, high-frequency actions can use Shardeum (if enabled)
    if (ShardeumNetworkConfig.isEnabled && _isHighFrequencyAction(actionType)) {
      return ChainRecommendation(
        recommendedChain: 'Shardeum',
        reason: 'High-frequency event suitable for scalability layer',
        shardeumSuitable: true,
        optimismRequired: false,
      );
    }

    // Default to Optimism
    return ChainRecommendation(
      recommendedChain: 'Optimism',
      reason: 'Default to canonical trust layer',
      shardeumSuitable: false,
    );
  }

  bool _isCriticalAction(CivicActionType type) {
    return [
      CivicActionType.attestation,
      CivicActionType.governanceVote,
      CivicActionType.identityVerification,
      CivicActionType.proofOfResolution,
      CivicActionType.badgeIssuance,
    ].contains(type);
  }

  bool _isHighFrequencyAction(CivicActionType type) {
    return [
      CivicActionType.eventLog,
      CivicActionType.participationRecord,
      CivicActionType.activityMetric,
    ].contains(type);
  }

  // ═══════════════════════════════════════════════════════════════════
  // INTERNAL HELPERS
  // ═══════════════════════════════════════════════════════════════════
  
  Future<dynamic> _makeRpcCall(String method, List<dynamic> params) async {
    try {
      final response = await http.post(
        Uri.parse(ShardeumNetworkConfig.rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': method,
          'params': params,
          'id': DateTime.now().millisecondsSinceEpoch,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'];
      }
    } catch (e) {
      debugPrint('[Shardeum] RPC call failed: $method - $e');
    }
    return null;
  }

  int _parseChainId(dynamic response) {
    if (response == null) return 0;
    if (response is int) return response;
    if (response is String) {
      return int.tryParse(response.replaceFirst('0x', ''), radix: 16) ?? 0;
    }
    return 0;
  }

  int _parseHexInt(dynamic response) {
    if (response == null) return 0;
    if (response is int) return response;
    if (response is String) {
      return int.tryParse(response.replaceFirst('0x', ''), radix: 16) ?? 0;
    }
    return 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════

enum ConnectionState {
  connected,
  disconnected,
  disabled,
  error,
}

class ShardeumConnectionStatus {
  final bool isConnected;
  final ConnectionState status;
  final String message;
  final DateTime checkedAt;
  final int? chainId;

  ShardeumConnectionStatus({
    required this.isConnected,
    required this.status,
    required this.message,
    required this.checkedAt,
    this.chainId,
  });

  Map<String, dynamic> toJson() => {
    'isConnected': isConnected,
    'status': status.name,
    'message': message,
    'checkedAt': checkedAt.toIso8601String(),
    'chainId': chainId,
  };
}

class ShardeumChainInfo {
  final String networkName;
  final int chainId;
  final bool isEnabled;
  final int? latestBlock;
  final int? gasPrice;
  final String? rpcUrl;
  final String? explorerUrl;
  final String? currencySymbol;
  final String architecturalRole;
  final List<String> capabilities;
  final List<String>? limitations;
  final DateTime? fetchedAt;
  final String? error;

  ShardeumChainInfo({
    required this.networkName,
    required this.chainId,
    required this.isEnabled,
    this.latestBlock,
    this.gasPrice,
    this.rpcUrl,
    this.explorerUrl,
    this.currencySymbol,
    required this.architecturalRole,
    required this.capabilities,
    this.limitations,
    this.fetchedAt,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'networkName': networkName,
    'chainId': chainId,
    'isEnabled': isEnabled,
    'latestBlock': latestBlock,
    'gasPrice': gasPrice,
    'rpcUrl': rpcUrl,
    'explorerUrl': explorerUrl,
    'currencySymbol': currencySymbol,
    'architecturalRole': architecturalRole,
    'capabilities': capabilities,
    'limitations': limitations,
    'fetchedAt': fetchedAt?.toIso8601String(),
    'error': error,
  };
}

enum CivicActionType {
  // Critical actions → Optimism only
  attestation,
  governanceVote,
  identityVerification,
  proofOfResolution,
  badgeIssuance,
  
  // High-frequency actions → Shardeum suitable
  eventLog,
  participationRecord,
  activityMetric,
}

class ChainRecommendation {
  final String recommendedChain;
  final String reason;
  final bool shardeumSuitable;
  final bool optimismRequired;

  ChainRecommendation({
    required this.recommendedChain,
    required this.reason,
    required this.shardeumSuitable,
    this.optimismRequired = true,
  });
}
