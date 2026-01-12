/// Environment-based Web3 configuration for GramPulse.
/// 
/// This file handles environment variables and configuration
/// for blockchain interactions across different environments.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grampulse/core/services/web3/network_config.dart';

/// Web3 configuration loaded from environment variables
class Web3Config {
  Web3Config._();
  
  static bool _initialized = false;
  
  /// Initialize Web3 configuration from .env file
  /// 
  /// Call this during app startup, after loading dotenv
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Load .env file if not already loaded
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }
    } catch (e) {
      // .env file might not exist in development
      // Use defaults in that case
      print('Web3Config: Failed to load .env file: $e');
    }
    
    _initialized = true;
  }
  
  /// Current environment (development, staging, production)
  static String get environment {
    if (!_initialized || !dotenv.isInitialized) {
      return 'development'; // Safe default
    }
    return dotenv.env['WEB3_ENVIRONMENT'] ?? 'development';
  }
  
  /// Whether we're in production mode
  static bool get isProduction => environment == 'production';
  
  /// Get the current network based on environment
  static Web3Network get currentNetwork {
    switch (environment) {
      case 'production':
        return Web3Network.optimismMainnet;
      case 'staging':
        return Web3Network.optimismSepolia;
      case 'development':
      default:
        return Web3Network.optimismSepolia;
    }
  }
  
  /// Get network configuration for current environment
  static NetworkConfig get networkConfig => 
      NetworkConfig.forNetwork(currentNetwork);
  
  /// RPC URL (can be overridden by env variable for custom RPC)
  static String get rpcUrl {
    if (!_initialized || !dotenv.isInitialized) {
      return networkConfig.rpcUrl; // Use network default
    }
    return dotenv.env['WEB3_RPC_URL'] ?? networkConfig.rpcUrl;
  }
  
  /// Backend attestation service URL
  /// Using localhost with ADB reverse port forwarding
  static String get attestationServiceUrl {
    // Using localhost:3000 with ADB reverse tcp:3000 tcp:3000
    // This allows the phone to reach the computer's localhost through USB
    const hardcodedUrl = 'http://localhost:3000';
    
    print('Web3Config: Using attestation URL: $hardcodedUrl');
    return hardcodedUrl;
    
    // Original code (commented out for testing):
    // if (!_initialized || !dotenv.isInitialized) {
    //   return 'http://localhost:3000'; // Safe default
    // }
    // return dotenv.env['ATTESTATION_SERVICE_URL'] ?? 'http://localhost:3000';
  }
  
  /// IPFS gateway URL for retrieving content
  static String get ipfsGatewayUrl {
    if (!_initialized || !dotenv.isInitialized) {
      return 'https://gateway.pinata.cloud/ipfs'; // Safe default
    }
    return dotenv.env['IPFS_GATEWAY_URL'] ?? 'https://gateway.pinata.cloud/ipfs';
  }
  
  /// IPFS API URL for uploading content
  static String get ipfsApiUrl {
    if (!_initialized || !dotenv.isInitialized) {
      return 'https://api.pinata.cloud'; // Safe default
    }
    return dotenv.env['IPFS_API_URL'] ?? 'https://api.pinata.cloud';
  }
  
  /// Pinata API key (for IPFS uploads)
  static String? get pinataApiKey {
    if (!_initialized || !dotenv.isInitialized) return null;
    return dotenv.env['PINATA_API_KEY'];
  }
  
  /// Pinata API secret
  static String? get pinataApiSecret {
    if (!_initialized || !dotenv.isInitialized) return null;
    return dotenv.env['PINATA_API_SECRET'];
  }
  
  /// Resolution schema UID on EAS
  static String? get resolutionSchemaUid {
    if (!_initialized || !dotenv.isInitialized) return null;
    return dotenv.env['EAS_RESOLUTION_SCHEMA_UID'];
  }
  
  /// Whether Web3 features are enabled
  /// 
  /// Can be disabled for offline-first scenarios
  static bool get web3Enabled {
    if (!_initialized || !dotenv.isInitialized) {
      return true; // Default to enabled in development
    }
    return dotenv.env['WEB3_ENABLED']?.toLowerCase() == 'true';
  }
  
  /// Debug mode for Web3 operations
  static bool get web3Debug {
    if (!_initialized || !dotenv.isInitialized) {
      return true; // Default to debug in development
    }
    return dotenv.env['WEB3_DEBUG']?.toLowerCase() == 'true';
  }
  
  /// API key for backend attestation service
  static String get apiKey {
    if (!_initialized || !dotenv.isInitialized) {
      return ''; // Empty key for development
    }
    return dotenv.env['ATTESTATION_API_KEY'] ?? '';
  }

  /// Singleton instance for dependency injection
  static Web3Config get instance => Web3Config._();

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (!web3Debug) return;
    
    print('=== Web3 Configuration ===');
    print('Environment: $environment');
    print('Network: ${networkConfig.name}');
    print('Chain ID: ${networkConfig.chainId}');
    print('RPC URL: $rpcUrl');
    print('Attestation Service: $attestationServiceUrl');
    print('IPFS Gateway: $ipfsGatewayUrl');
    print('Web3 Enabled: $web3Enabled');
    print('========================');
  }
}
