/// GramPulse Reputation Service - Flutter Client
///
/// Client for interacting with the reputation system backend.
/// Handles reputation scores, badges, and leaderboards.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/web3_config.dart';

/// Badge type enum matching backend
enum BadgeType {
  quickResolver(1),
  communityHero(2),
  consistencyStar(3),
  firstResponder(4),
  milestone100(5),
  milestone500(6),
  milestone1000(7),
  topPerformer(8),
  innovationAward(9),
  citizenFavorite(10);

  final int id;
  const BadgeType(this.id);

  static BadgeType? fromId(int id) {
    return BadgeType.values.firstWhere(
      (b) => b.id == id,
      orElse: () => BadgeType.quickResolver,
    );
  }

  String get displayName {
    switch (this) {
      case BadgeType.quickResolver:
        return 'Quick Resolver';
      case BadgeType.communityHero:
        return 'Community Hero';
      case BadgeType.consistencyStar:
        return 'Consistency Star';
      case BadgeType.firstResponder:
        return 'First Responder';
      case BadgeType.milestone100:
        return '100 Issues Resolved';
      case BadgeType.milestone500:
        return '500 Issues Resolved';
      case BadgeType.milestone1000:
        return '1000 Issues Resolved';
      case BadgeType.topPerformer:
        return 'Top Performer';
      case BadgeType.innovationAward:
        return 'Innovation Award';
      case BadgeType.citizenFavorite:
        return 'Citizen Favorite';
    }
  }

  /// Icon code point for Material Icons (use with IconData)
  int get iconCode {
    switch (this) {
      case BadgeType.quickResolver:
        return 0xe8e8; // bolt
      case BadgeType.communityHero:
        return 0xe7fd; // people
      case BadgeType.consistencyStar:
        return 0xe838; // star
      case BadgeType.firstResponder:
        return 0xe566; // local_fire_department
      case BadgeType.milestone100:
        return 0xe8e5; // verified
      case BadgeType.milestone500:
        return 0xe80e; // workspace_premium
      case BadgeType.milestone1000:
        return 0xea23; // emoji_events
      case BadgeType.topPerformer:
        return 0xeabc; // military_tech
      case BadgeType.innovationAward:
        return 0xe90f; // lightbulb
      case BadgeType.citizenFavorite:
        return 0xe87d; // favorite
    }
  }

  /// Badge color
  int get colorValue {
    switch (this) {
      case BadgeType.quickResolver:
        return 0xFFFF9800; // Orange
      case BadgeType.communityHero:
        return 0xFF2196F3; // Blue
      case BadgeType.consistencyStar:
        return 0xFFFFC107; // Amber
      case BadgeType.firstResponder:
        return 0xFFF44336; // Red
      case BadgeType.milestone100:
        return 0xFF4CAF50; // Green
      case BadgeType.milestone500:
        return 0xFF9C27B0; // Purple
      case BadgeType.milestone1000:
        return 0xFFFFD700; // Gold
      case BadgeType.topPerformer:
        return 0xFFE91E63; // Pink
      case BadgeType.innovationAward:
        return 0xFF00BCD4; // Cyan
      case BadgeType.citizenFavorite:
        return 0xFFE91E63; // Pink
    }
  }
}

/// Badge model
class Badge {
  final String id;
  final BadgeType type;
  final String? metadata;
  final DateTime? awardedAt;
  final bool onChain;

  Badge({
    required this.id,
    required this.type,
    this.metadata,
    this.awardedAt,
    this.onChain = false,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    int typeId = 1;
    if (json['type'] != null) {
      typeId = json['type'] is int ? json['type'] : int.tryParse(json['type'].toString()) ?? 1;
    } else if (json['metadata'] != null) {
      try {
        final meta = json['metadata'] is String ? jsonDecode(json['metadata']) : json['metadata'];
        typeId = meta['type'] ?? 1;
      } catch (_) {}
    }

    return Badge(
      id: json['id']?.toString() ?? json['badgeId']?.toString() ?? '',
      type: BadgeType.fromId(typeId) ?? BadgeType.quickResolver,
      metadata: json['metadata'] is String ? json['metadata'] : jsonEncode(json['metadata']),
      awardedAt: json['awardedAt'] != null 
          ? (json['awardedAt'] is int 
              ? DateTime.fromMillisecondsSinceEpoch(json['awardedAt']) 
              : DateTime.tryParse(json['awardedAt'].toString()))
          : null,
      onChain: json['onChain'] ?? false,
    );
  }
}

/// Reputation score model
class ReputationScore {
  final String address;
  final int score;
  final bool onChain;
  final int rank;

  ReputationScore({
    required this.address,
    required this.score,
    this.onChain = false,
    this.rank = 0,
  });

  factory ReputationScore.fromJson(Map<String, dynamic> json) {
    return ReputationScore(
      address: json['address'] ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score'].toString()) ?? 0,
      onChain: json['onChain'] ?? false,
      rank: json['rank'] ?? 0,
    );
  }

  /// Get tier based on score
  String get tier {
    if (score >= 10000) return 'Legendary';
    if (score >= 5000) return 'Master';
    if (score >= 2000) return 'Expert';
    if (score >= 500) return 'Skilled';
    if (score >= 100) return 'Active';
    return 'Newcomer';
  }

  /// Get tier color
  int get tierColor {
    if (score >= 10000) return 0xFFFFD700; // Gold
    if (score >= 5000) return 0xFF9400D3; // Purple
    if (score >= 2000) return 0xFF1E90FF; // Blue
    if (score >= 500) return 0xFF32CD32; // Green
    if (score >= 100) return 0xFFFFA500; // Orange
    return 0xFF808080; // Gray
  }
}

/// Reputation update result
class ReputationUpdateResult {
  final bool success;
  final String address;
  final int pointsAdded;
  final int? newScore;
  final String reason;
  final String? txHash;
  final bool onChain;
  final ReputationBreakdown? breakdown;

  ReputationUpdateResult({
    required this.success,
    required this.address,
    required this.pointsAdded,
    this.newScore,
    required this.reason,
    this.txHash,
    this.onChain = false,
    this.breakdown,
  });

  factory ReputationUpdateResult.fromJson(Map<String, dynamic> json) {
    return ReputationUpdateResult(
      success: json['success'] ?? false,
      address: json['address'] ?? '',
      pointsAdded: json['pointsAdded'] ?? 0,
      newScore: json['newScore'],
      reason: json['reason'] ?? '',
      txHash: json['txHash'],
      onChain: json['onChain'] ?? false,
      breakdown: json['breakdown'] != null 
          ? ReputationBreakdown.fromJson(json['breakdown']) 
          : null,
    );
  }
}

/// Reputation breakdown model
class ReputationBreakdown {
  final int base;
  final int quickBonus;
  final int firstResponder;
  final int feedback;
  final int total;

  ReputationBreakdown({
    required this.base,
    required this.quickBonus,
    required this.firstResponder,
    required this.feedback,
    required this.total,
  });

  factory ReputationBreakdown.fromJson(Map<String, dynamic> json) {
    return ReputationBreakdown(
      base: json['base'] ?? 0,
      quickBonus: json['quickBonus'] ?? 0,
      firstResponder: json['firstResponder'] ?? 0,
      feedback: json['feedback'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

/// Leaderboard entry
class LeaderboardEntry {
  final String address;
  final int score;
  final int rank;
  final String? displayName;

  LeaderboardEntry({
    required this.address,
    required this.score,
    required this.rank,
    this.displayName,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int index) {
    return LeaderboardEntry(
      address: json['address'] ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score'].toString()) ?? 0,
      rank: index + 1,
      displayName: json['displayName'],
    );
  }

  /// Get anonymized display address
  String get shortAddress {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}

/// Reputation Service
class ReputationService {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);
  
  ReputationService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  String get _baseUrl => Web3Config.attestationServiceUrl;
  
  // Debug getter
  String get debugBaseUrl => _baseUrl;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Web3Config.apiKey.isNotEmpty) 'x-api-key': Web3Config.apiKey,
  };

  Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json',
  };

  /// Get reputation score for an address
  Future<ReputationScore> getReputationScore(String address) async {
    try {
      debugPrint('ReputationService: Getting score from $_baseUrl/reputation/score/$address');
      final response = await _client.get(
        Uri.parse('$_baseUrl/reputation/score/$address'),
        headers: _publicHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReputationScore.fromJson(data['data']);
      } else {
        throw ReputationException('Failed to get reputation score');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Get badges for an address
  Future<List<Badge>> getBadges(String address) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/reputation/badges/$address'),
        headers: _publicHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final badges = data['data']['badges'] as List<dynamic>? ?? [];
        return badges.map((b) => Badge.fromJson(b)).toList();
      } else {
        throw ReputationException('Failed to get badges');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Add reputation points (requires auth)
  Future<ReputationUpdateResult> addReputationPoints({
    required String address,
    required int points,
    required String reason,
    String? issueId,
    String? category,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/reputation/points'),
        headers: _headers,
        body: jsonEncode({
          'address': address,
          'points': points,
          'reason': reason,
          if (issueId != null) 'issueId': issueId,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReputationUpdateResult.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw ReputationException(error['error'] ?? 'Failed to add reputation points');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Award a badge (requires auth)
  Future<Badge> awardBadge({
    required String address,
    required BadgeType badgeType,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/reputation/badge'),
        headers: _headers,
        body: jsonEncode({
          'address': address,
          'badgeType': badgeType.id,
          if (reason != null) 'reason': reason,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Badge.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw ReputationException(error['error'] ?? 'Failed to award badge');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Process resolution reputation (requires auth)
  Future<ReputationUpdateResult> processResolutionReputation({
    required String resolverAddress,
    required String issueId,
    double? resolutionTimeHours,
    int? rating,
    bool isFirstResponder = false,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/reputation/resolution'),
        headers: _headers,
        body: jsonEncode({
          'resolverAddress': resolverAddress,
          'issueId': issueId,
          if (resolutionTimeHours != null) 'resolutionTime': resolutionTimeHours,
          if (rating != null) 'rating': rating,
          'isFirstResponder': isFirstResponder,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReputationUpdateResult.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw ReputationException(error['error'] ?? 'Failed to process resolution reputation');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Get leaderboard (public)
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      debugPrint('ReputationService: Getting leaderboard from $_baseUrl/reputation/leaderboard?limit=$limit');
      final response = await _client.get(
        Uri.parse('$_baseUrl/reputation/leaderboard?limit=$limit'),
        headers: _publicHeaders,
      ).timeout(_timeout);

      debugPrint('ReputationService: Got response ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final leaderboard = data['data']['leaderboard'] as List<dynamic>? ?? [];
        return leaderboard.asMap().entries.map((e) => 
          LeaderboardEntry.fromJson(e.value, e.key)
        ).toList();
      } else {
        throw ReputationException('Failed to get leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ReputationService getLeaderboard ERROR: $e');
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Get badge type definitions
  Future<List<Map<String, dynamic>>> getBadgeTypes() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/reputation/badge-types'),
        headers: _publicHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw ReputationException('Failed to get badge types');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  /// Get reputation point values
  Future<Map<String, int>> getPointValues() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/reputation/point-values'),
        headers: _publicHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, int>.from(data['data'] ?? {});
      } else {
        throw ReputationException('Failed to get point values');
      }
    } catch (e) {
      if (e is ReputationException) rethrow;
      throw ReputationException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Reputation exception
class ReputationException implements Exception {
  final String message;
  ReputationException(this.message);
  
  @override
  String toString() => 'ReputationException: $message';
}
