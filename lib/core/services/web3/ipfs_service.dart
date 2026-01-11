/// GramPulse IPFS Service
///
/// Handles uploading proof files to IPFS via the attestation backend.
/// This service is used when resolving grievances to store immutable
/// proof of the resolution.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/web3_config.dart';

/// Result of an IPFS upload
class IPFSUploadResult {
  final bool success;
  final String? cid;
  final String? gatewayUrl;
  final String? error;
  final int? size;

  IPFSUploadResult({
    required this.success,
    this.cid,
    this.gatewayUrl,
    this.error,
    this.size,
  });

  factory IPFSUploadResult.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>;
      return IPFSUploadResult(
        success: true,
        cid: data['cid'] as String?,
        gatewayUrl: data['gatewayUrl'] as String?,
        size: data['size'] as int?,
      );
    } else {
      return IPFSUploadResult(
        success: false,
        error: json['message'] as String? ?? 'Unknown error',
      );
    }
  }
}

/// Result of a proof package upload
class ProofPackageResult {
  final bool success;
  final String? packageCid;
  final String? packageUrl;
  final List<MediaFileResult> mediaFiles;
  final String? error;

  ProofPackageResult({
    required this.success,
    this.packageCid,
    this.packageUrl,
    this.mediaFiles = const [],
    this.error,
  });

  factory ProofPackageResult.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>;
      final mediaList = (data['mediaFiles'] as List<dynamic>?)
          ?.map((m) => MediaFileResult.fromJson(m as Map<String, dynamic>))
          .toList() ?? [];
      
      return ProofPackageResult(
        success: true,
        packageCid: data['packageCid'] as String?,
        packageUrl: data['packageUrl'] as String?,
        mediaFiles: mediaList,
      );
    } else {
      return ProofPackageResult(
        success: false,
        error: json['message'] as String? ?? 'Unknown error',
      );
    }
  }
}

/// Individual media file result
class MediaFileResult {
  final String cid;
  final String fileName;
  final String mimeType;
  final String gatewayUrl;

  MediaFileResult({
    required this.cid,
    required this.fileName,
    required this.mimeType,
    required this.gatewayUrl,
  });

  factory MediaFileResult.fromJson(Map<String, dynamic> json) {
    return MediaFileResult(
      cid: json['cid'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      gatewayUrl: json['gatewayUrl'] as String,
    );
  }
}

/// IPFS Service for GramPulse
///
/// Provides methods to upload proof files to IPFS through the backend
class IPFSService {
  static IPFSService? _instance;
  
  final String _baseUrl;
  final String _apiKey;
  final http.Client _client;

  IPFSService._({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
  })  : _baseUrl = baseUrl,
        _apiKey = apiKey,
        _client = client ?? http.Client();

  /// Get singleton instance
  static IPFSService get instance {
    if (_instance == null) {
      final config = Web3Config.instance;
      _instance = IPFSService._(
        baseUrl: config.attestationServiceUrl,
        apiKey: config.apiKey,
      );
    }
    return _instance!;
  }

  /// Initialize with custom configuration (for testing)
  static void initialize({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
  }) {
    _instance = IPFSService._(
      baseUrl: baseUrl,
      apiKey: apiKey,
      client: client,
    );
  }

  /// Reset instance (for testing)
  static void reset() {
    _instance = null;
  }

  /// Upload a single file to IPFS
  ///
  /// [file] - The file to upload
  /// [grievanceId] - Associated grievance ID (optional)
  ///
  /// Returns [IPFSUploadResult] with CID and gateway URL
  Future<IPFSUploadResult> uploadFile(
    File file, {
    String? grievanceId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/ipfs/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-key'] = _apiKey;

      // Add file
      final fileName = file.path.split(Platform.pathSeparator).last;
      final mimeType = _getMimeType(fileName);
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ));

      // Add grievance ID if provided
      if (grievanceId != null) {
        request.fields['grievanceId'] = grievanceId;
      }

      // Send request
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return IPFSUploadResult.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return IPFSUploadResult(
          success: false,
          error: json['message'] as String? ?? 'Upload failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return IPFSUploadResult(
        success: false,
        error: 'Upload error: $e',
      );
    }
  }

  /// Upload file from bytes
  Future<IPFSUploadResult> uploadBytes(
    Uint8List bytes,
    String fileName, {
    String? grievanceId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/ipfs/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-key'] = _apiKey;

      // Add file
      final mimeType = _getMimeType(fileName);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      // Add grievance ID if provided
      if (grievanceId != null) {
        request.fields['grievanceId'] = grievanceId;
      }

      // Send request
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return IPFSUploadResult.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return IPFSUploadResult(
          success: false,
          error: json['message'] as String? ?? 'Upload failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return IPFSUploadResult(
        success: false,
        error: 'Upload error: $e',
      );
    }
  }

  /// Create a complete proof-of-resolution package
  ///
  /// This uploads all proof files and creates a metadata package on IPFS
  ///
  /// [grievanceId] - Firebase document ID of the grievance
  /// [villageId] - Village identifier
  /// [resolverRole] - Role of the resolver (officer/volunteer)
  /// [resolverId] - User ID of the resolver
  /// [description] - Resolution description
  /// [files] - List of proof files to upload
  ///
  /// Returns [ProofPackageResult] with package CID
  Future<ProofPackageResult> createProofPackage({
    required String grievanceId,
    required String villageId,
    required String resolverRole,
    required String resolverId,
    String? description,
    List<File>? files,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/ipfs/proof-package');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-key'] = _apiKey;

      // Add fields
      request.fields['grievanceId'] = grievanceId;
      request.fields['villageId'] = villageId;
      request.fields['resolverRole'] = resolverRole;
      request.fields['resolverId'] = resolverId;
      if (description != null) {
        request.fields['description'] = description;
      }

      // Add files
      if (files != null) {
        for (final file in files) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          final mimeType = _getMimeType(fileName);
          
          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(mimeType),
          ));
        }
      }

      // Send request
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProofPackageResult.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProofPackageResult(
          success: false,
          error: json['message'] as String? ?? 'Package creation failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ProofPackageResult(
        success: false,
        error: 'Package error: $e',
      );
    }
  }

  /// Get gateway URL for a CID
  String getGatewayUrl(String cid) {
    // Use Pinata gateway by default
    return 'https://gateway.pinata.cloud/ipfs/$cid';
  }

  /// Check if IPFS service is available
  Future<bool> isAvailable() async {
    try {
      final uri = Uri.parse('$_baseUrl/ipfs/health');
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      default:
        return 'application/octet-stream';
    }
  }
}
