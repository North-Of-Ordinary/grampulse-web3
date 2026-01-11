import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic)? dataFromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown message',
      data: json['data'] != null && dataFromJson != null ? dataFromJson(json['data']) : null,
      statusCode: json['statusCode'] ?? 500,
    );
  }
}

class ApiService {
  // Use --dart-define to override at run-time: --dart-define=API_BASE=http://<host>:5000/api
  // Use localhost with ADB reverse tunnel for Android device connection
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:5000/api',
  );

  // Headers with token
  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    print('🔑 API HEADERS: ${headers.keys.join(', ')}');
    if (token != null) {
      print('🎫 TOKEN PRESENT: ${token.substring(0, 20)}...');
    } else {
      print('❌ NO TOKEN FOUND');
    }
    
    return headers;
  }

  // Headers for multipart requests
  Future<Map<String, String>> _getMultipartHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Save JWT token
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Get JWT token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Clear JWT token (logout)
  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Request OTP
  Future<ApiResponse<dynamic>> requestOtp(String phone, {String? name, String? village}) async {
    print('🎯 API SERVICE: Requesting OTP for $phone');
    
    final body = <String, dynamic>{'phone': phone};
    if (name != null) body['name'] = name;
    if (village != null) body['village'] = village;
    
    return await post(
        '/auth/request-otp',
        body,
        (data) => data,
    );
  }

  // Verify OTP
  Future<ApiResponse<dynamic>> verifyOtp(String phone, String otp) async {
    print('🎯 API SERVICE: Verifying OTP for $phone');
    
    final response = await post(
        '/auth/verify-otp',
        {'phone': phone, 'otp': otp},
        (data) => data,
    );
    
    // Save token if verification successful
    if (response.success && response.data != null && response.data['token'] != null) {
      await saveToken(response.data['token']);
      print('✅ Token saved successfully');
    }
    
    return response;
  }

  // Get categories
  Future<ApiResponse<List<dynamic>>> getCategories() async {
    print('🎯 API SERVICE: Getting categories');
    return await get('/incidents/categories', (data) => data as List<dynamic>);
  }

  // Get my incidents
  Future<ApiResponse<List<dynamic>>> getMyIncidents() async {
    print('🎯 API SERVICE: Getting my incidents');
    return await get('/incidents/my', (data) => data as List<dynamic>);
  }

  // Get nearby incidents (now returns ALL incidents for citizen dashboard)
  Future<ApiResponse<List<dynamic>>> getNearbyIncidents({
    double? latitude,  // Made optional
    double? longitude, // Made optional
    double radius = 5000, // radius in meters
  }) async {
    print('🎯 API SERVICE: Getting all incidents for citizen dashboard');
    
    // For citizen dashboard, we want ALL incidents, not just nearby ones
    // This ensures the nearby issues count matches the statistics
    String endpoint = '/incidents/nearby';
    
    // Add location parameters if provided (for future geolocation filtering if needed)
    if (latitude != null && longitude != null) {
      endpoint += '?lat=$latitude&lng=$longitude&radius=$radius';
      print('🌍 Using location: lat: $latitude, lng: $longitude');
    }
    
    final response = await get(
      endpoint,
      (data) => data as List<dynamic>,
    );
    
    print('📊 NEARBY INCIDENTS RESPONSE: Success=${response.success}, Data Length=${response.data?.length ?? 0}');
    if (response.data != null) {
      print('📋 First incident preview: ${response.data!.isNotEmpty ? response.data![0] : 'No incidents'}');
    }
    
    return response;
  }

  // Get incident statistics
  Future<ApiResponse<Map<String, dynamic>>> getIncidentStatistics() async {
    print('🎯 API SERVICE: Getting incident statistics');
    return await get('/incidents/statistics', (data) => data as Map<String, dynamic>);
  }

  // Create incident
  Future<ApiResponse<dynamic>> createIncident({
    required String title,
    required String description,
    required String categoryId,
    required Map<String, dynamic> location,
    int severity = 1, // 1: Low, 2: Medium, 3: High
    bool isAnonymous = false,
  }) async {
    print('🎯 API SERVICE: Creating incident - $title');
    return await post(
        '/incidents',
        {
          'title': title,
          'description': description,
          'categoryId': categoryId,
          'location': location,
          'severity': severity,
          'isAnonymous': isAnonymous,
        },
        (data) => data,
    );
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Test token with health check
    final healthResponse = await health();
    return healthResponse.success;
  }


  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    dynamic body,
    T Function(dynamic)? fromJson,
    ) async {
    try {
        print('🚀 ATTEMPTING REQUEST TO: $baseUrl$endpoint');
        print('📤 SENDING DATA: $body');
        
        final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
        ).timeout(
        const Duration(seconds: 30), // ✅ Increased to 30 seconds
        );
        
        print('📥 RESPONSE STATUS: ${response.statusCode}');
        print('📥 RESPONSE BODY: ${response.body}');
        
        return _processResponse(response, fromJson);
    } catch (e) {
        print('❌ NETWORK ERROR: $e');
        return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
        );
    }
  }

  // Simple connectivity check
  Future<ApiResponse<dynamic>> health() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return _processResponse(response, (d) => d);
    } catch (e) {
      return ApiResponse(success: false, message: 'Health check failed: $e', statusCode: 500);
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    dynamic body,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );
      
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Multipart request for file uploads
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file,
    String fieldName,
    Map<String, String> fields,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      
      request.headers.addAll(await _getMultipartHeaders());
      request.fields.addAll(fields);
      
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Process HTTP response
  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final responseBody = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Successful response
        return ApiResponse(
          success: responseBody['success'] ?? true,
          message: responseBody['message'] ?? 'Success',
          data: responseBody['data'] != null && fromJson != null 
              ? fromJson(responseBody['data']) 
              : null,
          statusCode: response.statusCode,
        );
      } else {
        // Error response
        return ApiResponse(
          success: false,
          message: responseBody['message'] ?? 'Server error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Invalid JSON or other parsing error
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // Profile Management API Endpoints

  /// Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      print('👤 API SERVICE: Getting user profile');
      
      final headers = await _getHeaders();
      print('🚀 ATTEMPTING REQUEST TO: $baseUrl/profile');
      print('🔑 API HEADERS: ${headers.keys.join(', ')}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      print('📥 RESPONSE STATUS: ${response.statusCode}');
      print('📥 RESPONSE BODY: ${response.body}');

      return _processResponse<Map<String, dynamic>>(
        response, 
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ GET PROFILE ERROR: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('✏️ API SERVICE: Updating user profile');
      print('📝 UPDATE DATA: $profileData');
      
      final headers = await _getHeaders();
      print('🚀 ATTEMPTING REQUEST TO: $baseUrl/profile');
      print('📤 SENDING DATA: $profileData');
      
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      print('📥 RESPONSE STATUS: ${response.statusCode}');
      print('📥 RESPONSE BODY: ${response.body}');

      return _processResponse<Map<String, dynamic>>(
        response, 
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ UPDATE PROFILE ERROR: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get profile completeness information
  Future<ApiResponse<Map<String, dynamic>>> getProfileCompleteness() async {
    try {
      print('🔍 API SERVICE: Getting profile completeness');
      
      final headers = await _getHeaders();
      print('🚀 ATTEMPTING REQUEST TO: $baseUrl/profile/completeness');
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile/completeness'),
        headers: headers,
      );

      print('📥 RESPONSE STATUS: ${response.statusCode}');
      print('📥 RESPONSE BODY: ${response.body}');

      return _processResponse<Map<String, dynamic>>(
        response, 
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ GET PROFILE COMPLETENESS ERROR: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Upload profile image
  Future<ApiResponse<Map<String, dynamic>>> uploadProfileImage(File imageFile) async {
    try {
      print('📸 API SERVICE: Uploading profile image');
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/upload-image'),
      );
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', imageFile.path),
      );

      print('🚀 ATTEMPTING UPLOAD TO: $baseUrl/profile/upload-image');
      print('📤 UPLOADING FILE: ${imageFile.path}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 RESPONSE STATUS: ${response.statusCode}');
      print('📥 RESPONSE BODY: ${response.body}');

      return _processResponse<Map<String, dynamic>>(
        response, 
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ UPLOAD PROFILE IMAGE ERROR: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Delete profile image
  Future<ApiResponse<Map<String, dynamic>>> deleteProfileImage() async {
    try {
      print('🗑️ API SERVICE: Deleting profile image');
      
      final headers = await _getHeaders();
      print('🚀 ATTEMPTING REQUEST TO: $baseUrl/profile/image');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/profile/image'),
        headers: headers,
      );

      print('📥 RESPONSE STATUS: ${response.statusCode}');
      print('📥 RESPONSE BODY: ${response.body}');

      return _processResponse<Map<String, dynamic>>(
        response, 
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ DELETE PROFILE IMAGE ERROR: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
