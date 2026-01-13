/// GramPulse Dashboard Service - Transparency Dashboard Client
///
/// Client for fetching public transparency dashboard data.
/// All endpoints are public - no authentication required.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/web3_config.dart';

/// Dashboard overview model
class DashboardOverview {
  final int totalAttestations;
  final int totalResolutions;
  final double averageResolutionTimeHours;
  final int categoriesTracked;
  final int panchayatsActive;
  final DateTime? lastUpdated;
  final NetworkInfo network;

  DashboardOverview({
    required this.totalAttestations,
    required this.totalResolutions,
    required this.averageResolutionTimeHours,
    required this.categoriesTracked,
    required this.panchayatsActive,
    this.lastUpdated,
    required this.network,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? json;
    return DashboardOverview(
      totalAttestations: summary['totalAttestations'] ?? 0,
      totalResolutions: summary['totalResolutions'] ?? summary['activePanchayats'] ?? 0,
      averageResolutionTimeHours: (summary['averageResolutionTimeHours'] ?? summary['averageResolutionTime'] ?? 0).toDouble(),
      categoriesTracked: summary['categoriesTracked'] ?? 0,
      panchayatsActive: summary['panchayatsActive'] ?? summary['activePanchayats'] ?? 0,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']) 
          : null,
      network: NetworkInfo.fromJson(json['network'] ?? {}),
    );
  }
}

/// Network info model
class NetworkInfo {
  final String name;
  final int chainId;
  final String easContract;

  NetworkInfo({
    required this.name,
    required this.chainId,
    required this.easContract,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      name: json['name'] ?? 'Unknown',
      chainId: json['chainId'] ?? 0,
      easContract: json['easContract'] ?? '',
    );
  }
}

/// Category statistics model
class CategoryStats {
  final String name;
  final int count;
  final double percentage;

  CategoryStats({
    required this.name,
    required this.count,
    required this.percentage,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      name: json['name'] ?? 'Unknown',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

/// Panchayat ranking model
class PanchayatRanking {
  final String panchayatId;
  final int totalResolutions;
  final double averageResolutionTimeHours;
  final int efficiencyScore;
  final int rank;

  PanchayatRanking({
    required this.panchayatId,
    required this.totalResolutions,
    required this.averageResolutionTimeHours,
    required this.efficiencyScore,
    this.rank = 0,
  });

  factory PanchayatRanking.fromJson(Map<String, dynamic> json, [int index = 0]) {
    return PanchayatRanking(
      panchayatId: json['panchayatId'] ?? '',
      totalResolutions: json['totalResolutions'] ?? 0,
      averageResolutionTimeHours: (json['averageResolutionTimeHours'] ?? 0).toDouble(),
      efficiencyScore: json['efficiencyScore'] ?? 0,
      rank: index + 1,
    );
  }

  /// Get efficiency grade (A-F)
  String get grade {
    if (efficiencyScore >= 90) return 'A+';
    if (efficiencyScore >= 80) return 'A';
    if (efficiencyScore >= 70) return 'B';
    if (efficiencyScore >= 60) return 'C';
    if (efficiencyScore >= 50) return 'D';
    return 'F';
  }

  /// Get grade color
  int get gradeColor {
    if (efficiencyScore >= 90) return 0xFF4CAF50; // Green
    if (efficiencyScore >= 80) return 0xFF8BC34A; // Light Green
    if (efficiencyScore >= 70) return 0xFFFFC107; // Amber
    if (efficiencyScore >= 60) return 0xFFFF9800; // Orange
    if (efficiencyScore >= 50) return 0xFFFF5722; // Deep Orange
    return 0xFFF44336; // Red
  }
}

/// Daily trend point model
class TrendPoint {
  final DateTime date;
  final int count;

  TrendPoint({
    required this.date,
    required this.count,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: DateTime.parse(json['date']),
      count: json['count'] ?? 0,
    );
  }
}

/// Trend data model
class TrendData {
  final List<TrendPoint> points;
  final int total;
  final double average;

  TrendData({
    required this.points,
    required this.total,
    required this.average,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    final trend = json['trend'] as List<dynamic>? ?? [];
    return TrendData(
      points: trend.map((p) => TrendPoint.fromJson(p)).toList(),
      total: json['total'] ?? 0,
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

/// Recent attestation model (anonymized)
class RecentAttestation {
  final String uid;
  final String? category;
  final String? panchayatId;
  final double? resolutionTimeHours;
  final DateTime timestamp;
  final String? officerHash;

  RecentAttestation({
    required this.uid,
    this.category,
    this.panchayatId,
    this.resolutionTimeHours,
    required this.timestamp,
    this.officerHash,
  });

  factory RecentAttestation.fromJson(Map<String, dynamic> json) {
    return RecentAttestation(
      uid: json['uid'] ?? '',
      category: json['category'],
      panchayatId: json['panchayatId'],
      resolutionTimeHours: json['resolutionTimeHours']?.toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) 
          : DateTime.now(),
      officerHash: json['officerHash'],
    );
  }

  /// Get short UID for display
  String get shortUid {
    if (uid.length > 16) {
      return '${uid.substring(0, 8)}...${uid.substring(uid.length - 8)}';
    }
    return uid;
  }
}

/// Aggregate statistics model
class AggregateStats {
  final DashboardOverview overview;
  final List<CategoryStats> topCategories;
  final List<PanchayatRanking> topPanchayats;
  final TrendData weeklyTrend;
  final DateTime generatedAt;

  AggregateStats({
    required this.overview,
    required this.topCategories,
    required this.topPanchayats,
    required this.weeklyTrend,
    required this.generatedAt,
  });

  factory AggregateStats.fromJson(Map<String, dynamic> json) {
    return AggregateStats(
      overview: DashboardOverview.fromJson({'summary': json['overview']}),
      topCategories: (json['topCategories'] as List<dynamic>? ?? [])
          .map((c) => CategoryStats.fromJson(c))
          .toList(),
      topPanchayats: (json['topPanchayats'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((e) => PanchayatRanking.fromJson(e.value, e.key))
          .toList(),
      weeklyTrend: TrendData.fromJson(json['weeklyTrend'] ?? {}),
      generatedAt: json['generatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['generatedAt']) 
          : DateTime.now(),
    );
  }
}

/// Dashboard Service
class DashboardService {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);
  
  DashboardService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  String get _baseUrl => Web3Config.attestationServiceUrl;
  
  // Debug getter to expose the base URL
  String get debugBaseUrl => _baseUrl;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Web3Config.apiKey.isNotEmpty) 'x-api-key': Web3Config.apiKey,
  };

  /// Get dashboard overview
  Future<DashboardOverview> getOverview() async {
    try {
      debugPrint('DashboardService: Getting overview from $_baseUrl/dashboard/overview');
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/overview'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardOverview.fromJson(data['data']);
      } else {
        throw DashboardException('Failed to get dashboard overview');
      }
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Get attestations by category
  Future<List<CategoryStats>> getCategoryStats() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/categories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final categories = data['data']['categories'] as List<dynamic>? ?? [];
        return categories.map((c) => CategoryStats.fromJson(c)).toList();
      } else {
        throw DashboardException('Failed to get category stats');
      }
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Get panchayat rankings
  Future<List<PanchayatRanking>> getPanchayatRankings() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/panchayats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rankings = data['data']['rankings'] as List<dynamic>? ?? [];
        return rankings.asMap().entries
            .map((e) => PanchayatRanking.fromJson(e.value, e.key))
            .toList();
      } else {
        throw DashboardException('Failed to get panchayat rankings');
      }
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Get daily trend
  Future<TrendData> getDailyTrend({int days = 30}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/trend?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TrendData.fromJson(data['data']);
      } else {
        throw DashboardException('Failed to get daily trend');
      }
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Get recent attestations
  Future<List<RecentAttestation>> getRecentAttestations({int limit = 10}) async {
    try {
      debugPrint('DashboardService: Getting recent from $_baseUrl/dashboard/recent?limit=$limit');
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/recent?limit=$limit'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attestations = data['data']['attestations'] as List<dynamic>? ?? [];
        return attestations.map((a) => RecentAttestation.fromJson(a)).toList();
      } else {
        throw DashboardException('Failed to get recent attestations');
      }
    } catch (e) {
      debugPrint('DashboardService getRecentAttestations ERROR: $e');
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Get aggregate statistics
  Future<AggregateStats> getAggregateStats() async {
    try {
      debugPrint('DashboardService: Getting stats from $_baseUrl/dashboard/stats');
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/stats'),
        headers: _headers,
      ).timeout(_timeout);

      debugPrint('DashboardService: Got response ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AggregateStats.fromJson(data['data']);
      } else {
        throw DashboardException('Failed to get aggregate stats: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DashboardService ERROR: $e');
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Export metrics for archival
  Future<Map<String, dynamic>> exportMetrics() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/export'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw DashboardException('Failed to export metrics');
      }
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Network error: $e');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/dashboard/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Dashboard health check failed: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Dashboard exception
class DashboardException implements Exception {
  final String message;
  DashboardException(this.message);
  
  @override
  String toString() => 'DashboardException: $message';
}
