import 'package:grampulse/core/config/app_config.dart';
import 'package:grampulse/core/services/api_service.dart';
import 'package:grampulse/features/citizen/domain/models/incident_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncidentRepository {
  final ApiService _apiService = ApiService();

  /// Check if we're in test bypass mode (mock auth token present)
  Future<bool> _isTestBypassMode() async {
    if (!AppConfig.showAuthBypass) return false;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.startsWith('test_bypass_token_');
  }

  /// Mock categories for testing
  List<IncidentCategory> _getMockCategories() {
    return [
      IncidentCategory(id: '1', name: 'Road & Infrastructure', description: 'Potholes, damaged roads, broken streetlights', icon: 'road'),
      IncidentCategory(id: '2', name: 'Water & Sanitation', description: 'Water supply issues, drainage problems', icon: 'water'),
      IncidentCategory(id: '3', name: 'Electricity', description: 'Power outages, damaged electrical infrastructure', icon: 'electric'),
      IncidentCategory(id: '4', name: 'Waste Management', description: 'Garbage collection, illegal dumping', icon: 'trash'),
      IncidentCategory(id: '5', name: 'Public Safety', description: 'Safety hazards, security concerns', icon: 'shield'),
    ];
  }

  /// Mock incidents for testing
  List<Incident> _getMockIncidents() {
    final mockUser = IncidentUser(id: 'test_user_001', name: 'Test User', phone: '9999999999');
    return [
      Incident(
        id: 'mock_1',
        title: 'Large Pothole on Main Road',
        description: 'A large pothole has formed near the market area causing traffic issues.',
        categoryId: '1',
        user: mockUser,
        status: 'NEW',
        severity: 2,
        location: IncidentLocation(latitude: 12.9716, longitude: 77.5946, address: 'Main Road, Near Market'),
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Incident(
        id: 'mock_2',
        title: 'Street Light Not Working',
        description: 'The street light near the school has been out for a week.',
        categoryId: '3',
        user: mockUser,
        status: 'IN_PROGRESS',
        severity: 1,
        location: IncidentLocation(latitude: 12.9720, longitude: 77.5950, address: 'School Road'),
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Incident(
        id: 'mock_3',
        title: 'Garbage Not Collected',
        description: 'Garbage has not been collected from our area for 3 days.',
        categoryId: '4',
        user: mockUser,
        status: 'RESOLVED',
        severity: 2,
        location: IncidentLocation(latitude: 12.9710, longitude: 77.5940, address: 'Residential Area Block A'),
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Mock statistics for testing
  IncidentStatistics _getMockStatistics() {
    return IncidentStatistics(
      newIncidents: 1,
      inProgress: 1,
      resolved: 1,
      myIncidents: 3,
    );
  }

  Future<List<IncidentCategory>> getCategories() async {
    // Return mock data in test bypass mode
    if (await _isTestBypassMode()) {
      return _getMockCategories();
    }

    try {
      final response = await _apiService.getCategories();
      if (response.success && response.data != null) {
        return (response.data as List)
            .map((json) => IncidentCategory.fromJson(json))
            .toList();
      }
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Incident>> getMyIncidents() async {
    // Return mock data in test bypass mode
    if (await _isTestBypassMode()) {
      return _getMockIncidents();
    }

    try {
      final response = await _apiService.getMyIncidents();
      if (response.success && response.data != null) {
        return (response.data as List)
            .map((json) => Incident.fromJson(json))
            .toList();
      }
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to load my incidents: $e');
    }
  }

  Future<List<Incident>> getNearbyIncidents({
    double? latitude,  // Made optional
    double? longitude, // Made optional
    double radius = 5000,
  }) async {
    // Return mock data in test bypass mode
    if (await _isTestBypassMode()) {
      return _getMockIncidents();
    }

    try {
      final response = await _apiService.getNearbyIncidents(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      if (response.success && response.data != null) {
        return (response.data as List)
            .map((json) => Incident.fromJson(json))
            .toList();
      }
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to load nearby incidents: $e');
    }
  }

  Future<IncidentStatistics> getStatistics() async {
    // Return mock data in test bypass mode
    if (await _isTestBypassMode()) {
      return _getMockStatistics();
    }

    try {
      final response = await _apiService.getIncidentStatistics();
      if (response.success && response.data != null) {
        return IncidentStatistics.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }

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
      final location = {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
      };

      final response = await _apiService.createIncident(
        title: title,
        description: description,
        categoryId: categoryId,
        location: location,
        severity: severity,
        isAnonymous: isAnonymous,
      );

      if (response.success && response.data != null) {
        return Incident.fromJson(response.data);
      }
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to create incident: $e');
    }
  }
}
