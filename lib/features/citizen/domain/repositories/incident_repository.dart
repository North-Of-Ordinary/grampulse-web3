import 'package:flutter/foundation.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:grampulse/features/citizen/domain/models/incident_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Incident Repository - Uses Supabase for all data operations (NO MOCKS)
class IncidentRepository {
  final SupabaseService _supabase = SupabaseService();

  /// UUID regex pattern for validation
  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
  );

  /// Check if a string is a valid UUID
  bool _isValidUuid(String? id) {
    if (id == null) return false;
    return _uuidRegex.hasMatch(id);
  }

  /// Get current user ID from SharedPreferences
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    // Validate that user_id is a proper UUID
    if (userId != null && !_isValidUuid(userId)) {
      debugPrint('[IncidentRepository] ⚠️ Invalid UUID format: $userId, clearing...');
      await prefs.remove('user_id');
      return null;
    }
    
    return userId;
  }

  /// Get all incident categories from Supabase
  Future<List<IncidentCategory>> getCategories() async {
    try {
      final data = await _supabase.getCategories();
      debugPrint('[IncidentRepository] ✅ Loaded ${data.length} categories from Supabase');
      return data.map((json) => IncidentCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? 'category',
      )).toList();
    } catch (e) {
      debugPrint('[IncidentRepository] ❌ getCategories error: $e');
      rethrow;
    }
  }

  /// Get incidents created by the current user
  Future<List<Incident>> getMyIncidents() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        debugPrint('[IncidentRepository] ⚠️ No user ID found, returning all incidents');
        final data = await _supabase.getAllIncidents();
        return data.map((json) => _mapToIncident(json)).toList();
      }

      final data = await _supabase.getMyIncidents(userId);
      debugPrint('[IncidentRepository] ✅ Loaded ${data.length} user incidents from Supabase');
      return data.map((json) => _mapToIncident(json)).toList();
    } catch (e) {
      debugPrint('[IncidentRepository] ❌ getMyIncidents error: $e');
      rethrow;
    }
  }

  /// Get all incidents (for nearby view)
  Future<List<Incident>> getNearbyIncidents({
    double? latitude,
    double? longitude,
    double radius = 5000,
  }) async {
    try {
      final data = await _supabase.getAllIncidents();
      debugPrint('[IncidentRepository] ✅ Loaded ${data.length} nearby incidents from Supabase');
      return data.map((json) => _mapToIncident(json)).toList();
    } catch (e) {
      debugPrint('[IncidentRepository] ❌ getNearbyIncidents error: $e');
      rethrow;
    }
  }

  /// Get incident statistics
  Future<IncidentStatistics> getStatistics() async {
    try {
      final userId = await _getCurrentUserId();
      final stats = await _supabase.getIncidentStatistics(reporterId: userId);
      
      debugPrint('[IncidentRepository] ✅ Stats from Supabase: $stats');
      return IncidentStatistics(
        newIncidents: stats['new'] ?? 0,
        inProgress: stats['in_progress'] ?? 0,
        resolved: stats['resolved'] ?? 0,
        myIncidents: stats['total'] ?? 0,
      );
    } catch (e) {
      debugPrint('[IncidentRepository] ❌ getStatistics error: $e');
      rethrow;
    }
  }

  /// Create a new incident
  Future<Incident> createIncident({
    required String title,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
    String? address,
    int severity = 1,
    bool isAnonymous = false,
  }) async {
    try {
      // Get or create user
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('user_id');
      final phone = prefs.getString('phone') ?? '+911234567890';
      final name = prefs.getString('user_name');

      if (userId == null) {
        // Create user in Supabase if not exists
        debugPrint('[IncidentRepository] Creating new user in Supabase...');
        final user = await _supabase.getOrCreateUser(phone, name: name);
        userId = user['id'] as String;
        await prefs.setString('user_id', userId);
      }

      final data = await _supabase.createIncident(
        title: title,
        description: description,
        categoryId: categoryId,
        reporterId: userId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        severity: severity,
        isAnonymous: isAnonymous,
      );

      debugPrint('[IncidentRepository] ✅ Created incident in Supabase: ${data['id']}');
      return _mapToIncident(data);
    } catch (e) {
      debugPrint('[IncidentRepository] ❌ createIncident error: $e');
      rethrow;
    }
  }

  /// Update incident status
  Future<Incident> updateStatus(String incidentId, String status, {String? notes}) async {
    try {
      final userId = await _getCurrentUserId();
      final data = await _supabase.updateIncidentStatus(
        incidentId,
        status,
        notes: notes,
        updatedBy: userId,
      );
      return _mapToIncident(data);
    } catch (e) {
      debugPrint('[IncidentRepository] ❌ updateStatus error: $e');
      rethrow;
    }
  }

  /// Map Supabase response to Incident model
  Incident _mapToIncident(Map<String, dynamic> json) {
    // Extract category info
    final categoryData = json['categories'] as Map<String, dynamic>?;
    
    // Extract user info
    final userData = json['users'] as Map<String, dynamic>?;
    
    return Incident(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as String,
      user: IncidentUser(
        id: json['reporter_id'] as String? ?? '',
        name: userData?['name'] as String? ?? 'Anonymous',
        phone: userData?['phone'] as String? ?? '',
      ),
      status: _mapStatus(json['status'] as String?),
      severity: json['severity'] as int? ?? 1,
      location: IncidentLocation(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        address: json['address'] as String?,
      ),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Map database status to model status
  String _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
        return 'NEW';
      case 'in_progress':
        return 'IN_PROGRESS';
      case 'resolved':
        return 'RESOLVED';
      case 'closed':
        return 'CLOSED';
      default:
        return 'NEW';
    }
  }
}
