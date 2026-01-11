/// Web3 Service for GramPulse blockchain interactions.
/// 
/// This service provides a clean abstraction layer for all blockchain
/// operations. It handles:
/// - Read-only blockchain queries
/// - Attestation verification
/// - Transaction status checking
/// 
/// NOTE: This service does NOT handle wallet management or signing.
/// All write operations go through the backend attestation service.
library;

import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import 'package:grampulse/core/config/web3_config.dart';
import 'package:grampulse/core/services/web3/network_config.dart';

/// Result of a Web3 operation
class Web3Result<T> {
  final bool success;
  final T? data;
  final String? error;
  
  const Web3Result.success(this.data) : success = true, error = null;
  const Web3Result.failure(this.error) : success = false, data = null;
  
  @override
  String toString() => success ? 'Success: $data' : 'Failure: $error';
}

/// Attestation data from EAS
class AttestationData {
  /// Unique identifier for the attestation
  final String uid;
  
  /// Schema UID used for this attestation
  final String schemaUid;
  
  /// Timestamp when attestation was created
  final DateTime timestamp;
  
  /// Address that created the attestation
  final String attester;
  
  /// Address the attestation is about (if applicable)
  final String? recipient;
  
  /// Whether the attestation is revoked
  final bool revoked;
  
  /// Raw attestation data
  final String data;
  
  const AttestationData({
    required this.uid,
    required this.schemaUid,
    required this.timestamp,
    required this.attester,
    this.recipient,
    required this.revoked,
    required this.data,
  });
  
  /// Check if this is a valid, non-revoked attestation
  bool get isValid => !revoked;
  
  @override
  String toString() => 'Attestation($uid, valid: $isValid)';
}

/// Web3 Service for GramPulse
/// 
/// Provides read-only blockchain access and verification capabilities.
/// All write operations are delegated to the backend attestation service.
class Web3Service {
  Web3Service._internal();
  
  static Web3Service? _instance;
  
  /// Singleton instance of Web3Service
  static Web3Service get instance {
    _instance ??= Web3Service._internal();
    return _instance!;
  }
  
  Web3Client? _client;
  NetworkConfig? _networkConfig;
  bool _initialized = false;
  
  /// Whether the service is initialized and ready
  bool get isInitialized => _initialized;
  
  /// Current network configuration
  NetworkConfig? get networkConfig => _networkConfig;
  
  /// Initialize the Web3 service
  /// 
  /// This sets up the read-only provider connection to the blockchain.
  /// Call this during app startup after [Web3Config.initialize].
  Future<Web3Result<void>> initialize() async {
    if (_initialized) {
      return const Web3Result.success(null);
    }
    
    try {
      // Ensure Web3Config is initialized
      await Web3Config.initialize();
      
      // Check if Web3 is enabled
      if (!Web3Config.web3Enabled) {
        _initialized = true;
        if (Web3Config.web3Debug) {
          print('Web3Service: Initialized in disabled mode');
        }
        return const Web3Result.success(null);
      }
      
      // Get network configuration
      _networkConfig = Web3Config.networkConfig;
      
      // Create HTTP client for RPC calls
      final httpClient = http.Client();
      
      // Create Web3 client with read-only provider
      _client = Web3Client(
        Web3Config.rpcUrl,
        httpClient,
      );
      
      // Verify connection by fetching chain ID
      final chainId = await _client!.getChainId();
      
      if (chainId.toInt() != _networkConfig!.chainId) {
        return Web3Result.failure(
          'Chain ID mismatch. Expected ${_networkConfig!.chainId}, got $chainId'
        );
      }
      
      _initialized = true;
      
      if (Web3Config.web3Debug) {
        print('Web3Service: Initialized on ${_networkConfig!.name}');
        print('Web3Service: Chain ID verified: $chainId');
      }
      
      return const Web3Result.success(null);
      
    } catch (e) {
      return Web3Result.failure('Failed to initialize Web3Service: $e');
    }
  }
  
  /// Get the current block number
  Future<Web3Result<int>> getBlockNumber() async {
    if (!_initialized || _client == null) {
      return const Web3Result.failure('Web3Service not initialized');
    }
    
    try {
      final blockNum = await _client!.getBlockNumber();
      return Web3Result.success(blockNum);
    } catch (e) {
      return Web3Result.failure('Failed to get block number: $e');
    }
  }
  
  /// Check if an address is valid
  bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get the balance of an address (for debugging/admin purposes)
  Future<Web3Result<BigInt>> getBalance(String address) async {
    if (!_initialized || _client == null) {
      return const Web3Result.failure('Web3Service not initialized');
    }
    
    try {
      final ethAddress = EthereumAddress.fromHex(address);
      final balance = await _client!.getBalance(ethAddress);
      return Web3Result.success(balance.getInWei);
    } catch (e) {
      return Web3Result.failure('Failed to get balance: $e');
    }
  }
  
  /// Verify an attestation exists on-chain
  /// 
  /// This is a read-only operation that checks if an attestation UID
  /// exists and is valid (not revoked).
  Future<Web3Result<bool>> verifyAttestation(String attestationUid) async {
    if (!_initialized) {
      return const Web3Result.failure('Web3Service not initialized');
    }
    
    if (!Web3Config.web3Enabled) {
      // In disabled mode, assume attestations are valid
      // This allows offline-first behavior
      return const Web3Result.success(true);
    }
    
    try {
      // For now, we'll verify through the backend service
      // In the future, we can add direct EAS contract calls
      final response = await http.get(
        Uri.parse('${Web3Config.attestationServiceUrl}/verify/$attestationUid'),
      );
      
      if (response.statusCode == 200) {
        return const Web3Result.success(true);
      } else if (response.statusCode == 404) {
        return const Web3Result.success(false);
      } else {
        return Web3Result.failure('Verification failed: ${response.body}');
      }
    } catch (e) {
      // Network errors shouldn't block app functionality
      if (Web3Config.web3Debug) {
        print('Web3Service: Verification failed (offline?): $e');
      }
      return const Web3Result.failure('Network error during verification');
    }
  }
  
  /// Get attestation details from the backend
  Future<Web3Result<AttestationData>> getAttestation(String attestationUid) async {
    if (!_initialized) {
      return const Web3Result.failure('Web3Service not initialized');
    }
    
    if (!Web3Config.web3Enabled) {
      return const Web3Result.failure('Web3 features are disabled');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${Web3Config.attestationServiceUrl}/attestation/$attestationUid'),
      );
      
      if (response.statusCode == 200) {
        // Parse response and return attestation data
        // This will be implemented in Phase 2
        return const Web3Result.failure('Not yet implemented');
      } else {
        return Web3Result.failure('Failed to get attestation: ${response.body}');
      }
    } catch (e) {
      return Web3Result.failure('Network error: $e');
    }
  }
  
  /// Get the explorer URL for a transaction
  String getTransactionUrl(String txHash) {
    if (_networkConfig == null) return '';
    return '${_networkConfig!.explorerUrl}/tx/$txHash';
  }
  
  /// Get the explorer URL for an attestation
  String getAttestationUrl(String attestationUid) {
    if (_networkConfig == null) return '';
    // EAS attestations can be viewed on the network explorer
    return '${_networkConfig!.explorerUrl}/address/${_networkConfig!.easContractAddress}';
  }
  
  /// Dispose of resources
  void dispose() {
    _client?.dispose();
    _client = null;
    _initialized = false;
  }
}
