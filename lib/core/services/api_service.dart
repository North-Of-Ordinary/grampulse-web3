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
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
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
    return await get('/incidents/categories', (data) => data as List<dynamic>);
  }

  // Get my incidents
  Future<ApiResponse<List<dynamic>>> getMyIncidents() async {
    return await get('/incidents/my', (data) => data as List<dynamic>);
  }

  // Create incident
  Future<ApiResponse<dynamic>> createIncident({
    required String title,
    required String description,
    required String category,
    required Map<String, dynamic> location,
    String priority = 'medium',
  }) async {
    return await post(
        '/incidents',
        {
          'title': title,
          'description': description,
          'category': category,
          'location': location,
          'priority': priority,
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
}
