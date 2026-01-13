// Shardeum Network Configuration
// 
// Architecture Role: Shardeum serves as the HIGH-THROUGHPUT CIVIC EVENT LAYER.
// It handles raw civic events with low cost and high scalability.
// 
// IMPORTANT: Optimism remains the CANONICAL TRUST LAYER.
// Shardeum scales events → Optimism certifies outcomes.
// 
// This configuration is DISABLED by default and should only be enabled
// for event logging purposes, never for critical governance actions.

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShardeumNetworkConfig {
  ShardeumNetworkConfig._();
  
  // ═══════════════════════════════════════════════════════════════════
  // NETWORK CONSTANTS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Shardeum EVM Testnet - Official RPC (Mezame testnet)
  static const String testnetRpcUrl = 'https://api-mezame.shardeum.org';
  
  /// Alternative RPC URLs for fallback
  static const List<String> fallbackRpcUrls = [
    'https://api-mezame.shardeum.org', // Official testnet
    'https://api.shardeum.org',         // Mainnet (fallback)
  ];
  
  /// Chain ID for Shardeum EVM Testnet (Mezame)
  static const int testnetChainId = 8119;
  
  /// Network name for display purposes
  static const String networkName = 'Shardeum EVM Testnet';
  
  /// Currency symbol
  static const String currencySymbol = 'SHM';
  
  /// Block explorer URL
  static const String explorerUrl = 'https://explorer-mezame.shardeum.org';
  
  // ═══════════════════════════════════════════════════════════════════
  // FEATURE FLAGS (Environment-Aware)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Master switch for Shardeum integration
  /// Can be overridden via SHARDEUM_ENABLED env variable
  static bool get isEnabled {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['SHARDEUM_ENABLED']?.toLowerCase() == 'true';
      }
    } catch (_) {}
    return false; // Default: OFF
  }
  
  /// Enable event logging to Shardeum
  static bool get enableEventLogging {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['SHARDEUM_EVENT_LOGGING']?.toLowerCase() == 'true';
      }
    } catch (_) {}
    return false;
  }
  
  /// Read-only mode flag - Shardeum should NEVER write critical data
  static const bool readOnlyMode = true;
  
  // ═══════════════════════════════════════════════════════════════════
  // RPC CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════
  
  /// Get RPC URL (can be overridden via environment)
  static String get rpcUrl {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['SHARDEUM_RPC_URL'] ?? testnetRpcUrl;
      }
    } catch (_) {}
    return testnetRpcUrl;
  }
  
  /// Get chain ID
  static int get chainId {
    try {
      if (dotenv.isInitialized) {
        final envChainId = dotenv.env['SHARDEUM_CHAIN_ID'];
        if (envChainId != null) {
          return int.tryParse(envChainId) ?? testnetChainId;
        }
      }
    } catch (_) {}
    return testnetChainId;
  }

  // ═══════════════════════════════════════════════════════════════════
  // ARCHITECTURE DOCUMENTATION
  // ═══════════════════════════════════════════════════════════════════
  
  /// Architectural role of Shardeum in GramPulse
  static const String architecturalRole = '''
┌─────────────────────────────────────────────────────────────────────┐
│                    GRAMPULSE MULTI-CHAIN ARCHITECTURE               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐    Events    ┌─────────────┐    Trust    ┌──────┐ │
│  │   Civic     │ ──────────▶  │  SHARDEUM   │ ──────────▶ │ OPT  │ │
│  │   Actions   │   (Scale)    │  Event Log  │  (Certify)  │      │ │
│  └─────────────┘              └─────────────┘             └──────┘ │
│                                                                     │
│  SHARDEUM ROLE:                                                    │
│  • High-throughput event ingestion                                 │
│  • Low-cost civic activity logging                                 │
│  • Scalability buffer for peak loads                               │
│  • NOT the source of truth                                         │
│                                                                     │
│  OPTIMISM ROLE:                                                    │
│  • Canonical trust layer                                           │
│  • Final attestations                                              │
│  • Proof-of-Resolution anchoring                                   │
│  • Source of truth for governance                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
''';

  /// What Shardeum handles
  static const List<String> shardeumHandles = [
    'Raw civic event logging',
    'High-frequency activity tracking',
    'Scalable participation metrics',
    'Cost-efficient data anchoring',
  ];

  /// What Shardeum does NOT handle
  static const List<String> shardeumDoesNotHandle = [
    'Final attestations (→ Optimism)',
    'Governance decisions (→ Optimism)',
    'Identity verification (→ Optimism)',
    'Proof-of-Resolution (→ Optimism)',
    'Cross-chain bridging',
    'Token transfers',
  ];

  // ═══════════════════════════════════════════════════════════════════
  // CONFIGURATION HELPERS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Check if Shardeum features should be shown in UI
  static bool get shouldShowInUI => isEnabled;
  
  /// Validate configuration state
  static bool get isValidConfiguration {
    if (!readOnlyMode) return false;
    if (enableEventLogging && !isEnabled) return false;
    return true;
  }

  /// Get configuration summary for debugging
  static Map<String, dynamic> get configSummary => {
    'network': networkName,
    'chainId': chainId,
    'rpcUrl': rpcUrl,
    'enabled': isEnabled,
    'readOnly': readOnlyMode,
    'eventLogging': enableEventLogging,
    'role': 'Civic Event Layer (Scale)',
  };
  
  /// Print configuration for debugging
  static void printConfig() {
    debugPrint('=== Shardeum Configuration ===');
    debugPrint('Network: $networkName');
    debugPrint('Chain ID: $chainId');
    debugPrint('RPC URL: $rpcUrl');
    debugPrint('Enabled: $isEnabled');
    debugPrint('Read-Only: $readOnlyMode');
    debugPrint('Event Logging: $enableEventLogging');
    debugPrint('==============================');
  }
}
