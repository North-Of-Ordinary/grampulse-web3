import 'dart:io';
import 'api_service.dart';

class User {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String role;
  final String? profilePicture;
  final bool isProfileComplete;

  User({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    required this.role,
    this.profilePicture,
    this.isProfileComplete = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'citizen',
      profilePicture: json['profilePicture'],
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }
}

class AuthService {
  final ApiService _apiService = ApiService();
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Request OTP
  Future<ApiResponse<void>> requestOtp(String phone) async {
    return await _apiService.post<void>(
      '/auth/request-otp',
      {'phone': phone},
      null,
    );
  }

  // Verify OTP
  Future<ApiResponse<User>> verifyOtp(String phone, String otp) async {
    final response = await _apiService.post<User>(
      '/auth/verify-otp',
      {
        'phone': phone,
        'otp': otp,
      },
      (data) {
        if (data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
        }
        
        if (data['token'] != null) {
          _apiService.saveToken(data['token']);
        }
        
        return _currentUser!;
      },
    );
    
    return response;
  }

  // Complete profile
  Future<ApiResponse<User>> completeProfile({
    required String name,
    required String role,
    String? email,
    File? profilePicture,
  }) async {
    if (profilePicture != null) {
      return await _apiService.uploadFile<User>(
        '/auth/complete-profile',
        profilePicture,
        'profilePicture',
        {
          'name': name,
          'role': role,
          if (email != null) 'email': email,
        },
        (data) {
          _currentUser = User.fromJson(data);
          return _currentUser!;
        },
      );
    } else {
      return await _apiService.post<User>(
        '/auth/complete-profile',
        {
          'name': name,
          'role': role,
          if (email != null) 'email': email,
        },
        (data) {
          _currentUser = User.fromJson(data);
          return _currentUser!;
        },
      );
    }
  }

  // Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _apiService.get<User>(
      '/auth/me',
      (data) {
        _currentUser = User.fromJson(data);
        return _currentUser!;
      },
    );
    
    return response;
  }

  // Check if user is authenticated - DISABLED for fresh profiles
  Future<bool> isAuthenticated() async {
    // Force fresh authentication every time
    await logout(); // Clear any existing tokens
    return false;
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
  }
}
