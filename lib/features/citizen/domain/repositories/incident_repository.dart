import 'package:grampulse/core/services/api_service.dart';
import 'package:grampulse/features/citizen/domain/models/incident_models.dart';

class IncidentRepository {
  final ApiService _apiService = ApiService();

  Future<List<IncidentCategory>> getCategories() async {
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
