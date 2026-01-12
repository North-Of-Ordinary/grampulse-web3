/// GramPulse Attestation Service
///
/// High-level service that combines IPFS uploads with EAS attestations
/// for creating verifiable proof-of-resolution records.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/web3_config.dart';
import 'ipfs_service.dart';

/// Result of an attestation operation
class AttestationResult {
  final bool success;
  final String? attestationUid;
  final String? transactionHash;
  final String? explorerUrl;
  final String? ipfsCid;
  final String? ipfsUrl;
  final String? error;
  final int? timestamp;

  AttestationResult({
    required this.success,
    this.attestationUid,
    this.transactionHash,
    this.explorerUrl,
    this.ipfsCid,
    this.ipfsUrl,
    this.error,
    this.timestamp,
  });

  factory AttestationResult.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>;
      return AttestationResult(
        success: true,
        attestationUid: data['attestationUid'] as String?,
        transactionHash: data['transactionHash'] as String?,
        explorerUrl: data['explorerUrl'] as String?,
        timestamp: data['timestamp'] as int?,
      );
    } else {
      return AttestationResult(
        success: false,
        error: json['message'] as String? ?? 'Unknown error',
      );
    }
  }

  /// Create a combined result with IPFS data
  AttestationResult copyWithIpfs({
    String? ipfsCid,
    String? ipfsUrl,
  }) {
    return AttestationResult(
      success: success,
      attestationUid: attestationUid,
      transactionHash: transactionHash,
      explorerUrl: explorerUrl,
      ipfsCid: ipfsCid ?? this.ipfsCid,
      ipfsUrl: ipfsUrl ?? this.ipfsUrl,
      error: error,
      timestamp: timestamp,
    );
  }
}

/// Verification result
class VerificationResult {
  final bool valid;
  final String? grievanceId;
  final String? villageId;
  final String? resolverRole;
  final String? ipfsHash;
  final int? resolutionTimestamp;
  final String? attester;
  final String? error;

  VerificationResult({
    required this.valid,
    this.grievanceId,
    this.villageId,
    this.resolverRole,
    this.ipfsHash,
    this.resolutionTimestamp,
    this.attester,
    this.error,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    if (json['valid'] == true) {
      final attestation = json['attestation'] as Map<String, dynamic>;
      final data = attestation['data'] as Map<String, dynamic>;
      
      return VerificationResult(
        valid: true,
        grievanceId: data['grievanceId'] as String?,
        villageId: data['villageId'] as String?,
        resolverRole: data['resolverRole'] as String?,
        ipfsHash: data['ipfsHash'] as String?,
        resolutionTimestamp: data['resolutionTimestamp'] as int?,
        attester: attestation['attester'] as String?,
      );
    } else {
      return VerificationResult(
        valid: false,
        error: json['error'] as String? ?? 'Invalid attestation',
      );
    }
  }
}

/// Attestation Service for GramPulse
///
/// Provides high-level methods for:
/// - Creating resolution attestations (with optional IPFS proof)
/// - Verifying attestations
/// - Checking service health
class AttestationService {
  static AttestationService? _instance;
  
  final String _baseUrl;
  final String _apiKey;
  final http.Client _client;
  final IPFSService _ipfsService;

  AttestationService._({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
    IPFSService? ipfsService,
  })  : _baseUrl = baseUrl,
        _apiKey = apiKey,
        _client = client ?? http.Client(),
        _ipfsService = ipfsService ?? IPFSService.instance;

  /// Get singleton instance
  static AttestationService get instance {
    if (_instance == null) {
      _instance = AttestationService._(
        baseUrl: Web3Config.attestationServiceUrl,
        apiKey: Web3Config.apiKey,
      );
    }
    return _instance!;
  }

  /// Initialize with custom configuration (for testing)
  static void initialize({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
    IPFSService? ipfsService,
  }) {
    _instance = AttestationService._(
      baseUrl: baseUrl,
      apiKey: apiKey,
      client: client,
      ipfsService: ipfsService,
    );
  }

  /// Reset instance (for testing)
  static void reset() {
    _instance = null;
  }

  /// Create a resolution attestation
  ///
  /// This is the main method for recording a grievance resolution on-chain.
  /// Optionally uploads proof files to IPFS first.
  ///
  /// [grievanceId] - Firebase document ID of the grievance
  /// [villageId] - Village identifier
  /// [resolverRole] - Role of the resolver (officer/volunteer/citizen)
  /// [resolverId] - User ID of the resolver
  /// [description] - Resolution description
  /// [proofFiles] - Optional list of proof files (images/videos)
  ///
  /// Returns [AttestationResult] with attestation UID and IPFS data
  Future<AttestationResult> createResolutionAttestation({
    required String grievanceId,
    required String villageId,
    required String resolverRole,
    required String resolverId,
    String? description,
    List<File>? proofFiles,
  }) async {
    String? ipfsCid;
    String? ipfsUrl;

    try {
      // Step 1: Upload proof files to IPFS (if any)
      if (proofFiles != null && proofFiles.isNotEmpty) {
        final ipfsAvailable = await _ipfsService.isAvailable();
        
        if (ipfsAvailable) {
          final proofResult = await _ipfsService.createProofPackage(
            grievanceId: grievanceId,
            villageId: villageId,
            resolverRole: resolverRole,
            resolverId: resolverId,
            description: description,
            files: proofFiles,
          );

          if (proofResult.success) {
            ipfsCid = proofResult.packageCid;
            ipfsUrl = proofResult.packageUrl;
          }
        }
      }

      // Step 2: Create on-chain attestation
      final uri = Uri.parse('$_baseUrl/attest/resolution');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: jsonEncode({
          'grievanceId': grievanceId,
          'villageId': villageId,
          'resolverRole': resolverRole,
          'ipfsHash': ipfsCid ?? '',
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = AttestationResult.fromJson(json);
        return result.copyWithIpfs(ipfsCid: ipfsCid, ipfsUrl: ipfsUrl);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AttestationResult(
          success: false,
          error: json['message'] as String? ?? 'Attestation failed: ${response.statusCode}',
          ipfsCid: ipfsCid,
          ipfsUrl: ipfsUrl,
        );
      }
    } catch (e) {
      return AttestationResult(
        success: false,
        error: 'Attestation error: $e',
        ipfsCid: ipfsCid,
        ipfsUrl: ipfsUrl,
      );
    }
  }

  /// Verify an attestation by UID
  ///
  /// [attestationUid] - The attestation UID (0x...)
  ///
  /// Returns [VerificationResult] with decoded attestation data
  Future<VerificationResult> verifyAttestation(String attestationUid) async {
    try {
      final uri = Uri.parse('$_baseUrl/verify/$attestationUid');
      final response = await _client.get(uri);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return VerificationResult.fromJson(json);
    } catch (e) {
      return VerificationResult(
        valid: false,
        error: 'Verification error: $e',
      );
    }
  }

  /// Check if attestation service is available
  Future<bool> isAvailable() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['status'] == 'healthy' && json['easInitialized'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get service health details
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'error': 'Failed to get health status'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  /// Get explorer URL for a transaction
  String getExplorerUrl(String transactionHash) {
    // Default to Optimism Sepolia explorer
    return 'https://sepolia-optimism.etherscan.io/tx/$transactionHash';
  }

  /// Get IPFS gateway URL for a CID
  String getIpfsUrl(String cid) {
    return _ipfsService.getGatewayUrl(cid);
  }
}
