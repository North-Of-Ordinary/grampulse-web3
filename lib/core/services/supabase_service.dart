import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Configuration for GramPulse
class SupabaseConfig {
  static const String supabaseUrl = 'https://mwciuegvujixznurjqbx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13Y2l1ZWd2dWppeHpudXJqcWJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMTcwMTksImV4cCI6MjA4Mzc5MzAxOX0.0ClcfdNFWaMPA_bODeq0Pn10uMAz2ljjT5PyCWVi_J4';
}

/// Supabase Service - Centralized database access for GramPulse
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  SupabaseClient? _client;

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('SupabaseService not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _isInitialized;

  /// Initialize Supabase - call this in main.dart before runApp
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('[Supabase] ✅ Initialized successfully');
    } catch (e) {
      debugPrint('[Supabase] ❌ Initialization failed: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await client
          .from('categories')
          .select('*, departments(name)')
          .order('name');
      debugPrint('[Supabase] ✅ Fetched ${response.length} categories');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getCategories error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DEPARTMENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final response = await client
          .from('departments')
          .select()
          .order('name');
      debugPrint('[Supabase] ✅ Fetched ${response.length} departments');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getDepartments error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // INCIDENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getIncidents({
    String? status,
    String? reporterId,
    int limit = 50,
  }) async {
    try {
      // Build query with filters first, then order and limit
      var query = client
          .from('incidents')
          .select('*, categories(name, icon), users(name, phone)');

      if (status != null) {
        query = query.eq('status', status);
      }
      if (reporterId != null) {
        query = query.eq('reporter_id', reporterId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      debugPrint('[Supabase] ✅ Fetched ${response.length} incidents');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getIncidents error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyIncidents(String reporterId) async {
    try {
      final response = await client
          .from('incidents')
          .select('*, categories(name, icon)')
          .eq('reporter_id', reporterId)
          .order('created_at', ascending: false);
      debugPrint('[Supabase] ✅ Fetched ${response.length} user incidents');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getMyIncidents error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllIncidents() async {
    try {
      final response = await client
          .from('incidents')
          .select('*, categories(name, icon), users(name)')
          .order('created_at', ascending: false);
      debugPrint('[Supabase] ✅ Fetched ${response.length} all incidents');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getAllIncidents error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getIncidentsByUser(String userId) async {
    try {
      final response = await client
          .from('incidents')
          .select('*, categories(name, icon), users(name)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      debugPrint('[Supabase] ✅ Fetched ${response.length} incidents for user $userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getIncidentsByUser error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createIncident({
    required String title,
    required String description,
    required String categoryId,
    required String reporterId,
    double? latitude,
    double? longitude,
    String? address,
    int severity = 1,
    bool isAnonymous = false,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'reporter_id': reporterId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'severity': severity,
        'is_anonymous': isAnonymous,
        'status': 'new',
      };

      final response = await client
          .from('incidents')
          .insert(data)
          .select()
          .single();

      debugPrint('[Supabase] ✅ Created incident: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('[Supabase] ❌ createIncident error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateIncidentStatus(
    String incidentId,
    String status, {
    String? notes,
    String? updatedBy,
  }) async {
    try {
      // Update incident
      final response = await client
          .from('incidents')
          .update({'status': status})
          .eq('id', incidentId)
          .select()
          .single();

      // Add update record
      if (notes != null || updatedBy != null) {
        await client.from('incident_updates').insert({
          'incident_id': incidentId,
          'status': status,
          'notes': notes,
          'updated_by': updatedBy,
        });
      }

      debugPrint('[Supabase] ✅ Updated incident $incidentId to $status');
      return response;
    } catch (e) {
      debugPrint('[Supabase] ❌ updateIncidentStatus error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATISTICS
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, int>> getIncidentStatistics({String? reporterId}) async {
    try {
      var query = client.from('incidents').select('status');
      if (reporterId != null) {
        query = query.eq('reporter_id', reporterId);
      }

      final response = await query;
      final stats = {
        'new': 0,
        'in_progress': 0,
        'resolved': 0,
        'total': response.length,
      };

      for (final incident in response) {
        final status = incident['status'] as String?;
        if (status == 'new') stats['new'] = stats['new']! + 1;
        if (status == 'in_progress') stats['in_progress'] = stats['in_progress']! + 1;
        if (status == 'resolved') stats['resolved'] = stats['resolved']! + 1;
      }

      debugPrint('[Supabase] ✅ Stats: $stats');
      return stats;
    } catch (e) {
      debugPrint('[Supabase] ❌ getIncidentStatistics error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // USERS
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();
      debugPrint('[Supabase] ✅ User lookup: ${response != null ? 'found' : 'not found'}');
      return response;
    } catch (e) {
      debugPrint('[Supabase] ❌ getUserByPhone error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String phone,
    String? name,
    String? village,
    String? district,
    String? state,
  }) async {
    try {
      final data = {
        'phone': phone,
        'name': name,
        'village': village,
        'district': district,
        'state': state,
        'role': 'citizen',
        'reputation_score': 0,
      };

      final response = await client
          .from('users')
          .insert(data)
          .select()
          .single();

      debugPrint('[Supabase] ✅ Created user: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('[Supabase] ❌ createUser error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrCreateUser(String phone, {String? name}) async {
    final existing = await getUserByPhone(phone);
    if (existing != null) return existing;
    return await createUser(phone: phone, name: name);
  }

  // ═══════════════════════════════════════════════════════════════════
  // OTP MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  Future<String> createOtp(String phone) async {
    try {
      // Generate 6-digit OTP
      final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Upsert OTP (replace if exists for same phone)
      await client.from('otp_requests').upsert({
        'phone': phone,
        'otp': otp,
        'verified': false,
        'expires_at': expiresAt.toIso8601String(),
      }, onConflict: 'phone');

      debugPrint('[Supabase] ✅ OTP created for $phone: $otp');
      return otp;
    } catch (e) {
      debugPrint('[Supabase] ❌ createOtp error: $e');
      rethrow;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final response = await client
          .from('otp_requests')
          .select()
          .eq('phone', phone)
          .eq('otp', otp)
          .eq('verified', false)
          .gte('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response != null) {
        // Mark as verified
        await client
            .from('otp_requests')
            .update({'verified': true})
            .eq('phone', phone);
        debugPrint('[Supabase] ✅ OTP verified for $phone');
        return true;
      }

      debugPrint('[Supabase] ❌ OTP verification failed for $phone');
      return false;
    } catch (e) {
      debugPrint('[Supabase] ❌ verifyOtp error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LEADERBOARD / REPUTATION
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await client
          .from('users')
          .select('id, name, village, reputation_score')
          .order('reputation_score', ascending: false)
          .limit(limit);
      debugPrint('[Supabase] ✅ Fetched ${response.length} leaderboard entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getLeaderboard error: $e');
      rethrow;
    }
  }

  Future<void> updateReputationScore(String userId, int scoreDelta) async {
    try {
      // Get current score
      final user = await client
          .from('users')
          .select('reputation_score')
          .eq('id', userId)
          .single();

      final currentScore = user['reputation_score'] as int? ?? 0;
      final newScore = currentScore + scoreDelta;

      await client
          .from('users')
          .update({'reputation_score': newScore})
          .eq('id', userId);

      debugPrint('[Supabase] ✅ Updated reputation for $userId: $currentScore -> $newScore');
    } catch (e) {
      debugPrint('[Supabase] ❌ updateReputationScore error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // OFFICERS
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getOfficerByPhone(String phone) async {
    try {
      final response = await client
          .from('officers')
          .select('*, departments(name)')
          .eq('phone', phone)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('[Supabase] ❌ getOfficerByPhone error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOfficers({String? departmentId}) async {
    try {
      var query = client
          .from('officers')
          .select('*, departments(name)')
          .eq('is_active', true);

      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ getOfficers error: $e');
      rethrow;
    }
  }
}
