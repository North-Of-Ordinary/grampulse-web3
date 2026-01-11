import 'dart:io';
import 'api_service.dart';

enum ReportCategory {
  WATER,
  ELECTRICITY,
  ROAD,
  SANITATION,
  EDUCATION,
  HEALTH,
  AGRICULTURE,
  OTHER
}

enum ReportStatus {
  PENDING,
  UNDER_REVIEW,
  ASSIGNED,
  IN_PROGRESS,
  RESOLVED,
  REJECTED
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Comment {
  final String id;
  final String text;
  final String userId;
  final String? userName;
  final String? userRole;
  final String? userProfilePicture;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    this.userName,
    this.userRole,
    this.userProfilePicture,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userRole: json['userRole'],
      userProfilePicture: json['userProfilePicture'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String address;
  final String district;
  final String state;
  final String pincode;
  final Location? location;
  final List<String>? images;
  final String userId;
  final String? userName;
  final List<Comment> comments;
  final String? assignedOfficerId;
  final String? assignedOfficerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.address,
    required this.district,
    required this.state,
    required this.pincode,
    this.location,
    this.images,
    required this.userId,
    this.userName,
    required this.comments,
    this.assignedOfficerId,
    this.assignedOfficerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'OTHER',
      status: json['status'] ?? 'PENDING',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      userId: json['userId'] ?? '',
      userName: json['userName'],
      comments: json['comments'] != null
          ? List<Comment>.from(
              json['comments'].map((x) => Comment.fromJson(x)))
          : [],
      assignedOfficerId: json['assignedOfficerId'],
      assignedOfficerName: json['assignedOfficerName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

class ReportService {
  final ApiService _apiService = ApiService();

  // Create a new report
  Future<ApiResponse<Report>> createReport({
    required String title,
    required String description,
    required String category,
    required String address,
    required String district,
    required String state,
    required String pincode,
    Location? location,
    List<File>? images,
  }) async {
    if (images != null && images.isNotEmpty) {
      // Handle multiple image uploads
      final request = {
        'title': title,
        'description': description,
        'category': category,
        'address': address,
        'district': district,
        'state': state,
        'pincode': pincode,
        if (location != null) 'location': location.toJson().toString(),
      };

      return await _apiService.uploadFile<Report>(
        '/reports',
        images.first, // First image
        'reportImages',
        Map<String, String>.from(request),
        (data) => Report.fromJson(data),
      );
    } else {
      return await _apiService.post<Report>(
        '/reports',
        {
          'title': title,
          'description': description,
          'category': category,
          'address': address,
          'district': district,
          'state': state,
          'pincode': pincode,
          if (location != null) 'location': location.toJson(),
        },
        (data) => Report.fromJson(data),
      );
    }
  }

  // Get all reports
  Future<ApiResponse<List<Report>>> getAllReports({
    String? status,
    String? category,
    String? district,
  }) async {
    String endpoint = '/reports';
    
    List<String> queryParams = [];
    if (status != null) queryParams.add('status=$status');
    if (category != null) queryParams.add('category=$category');
    if (district != null) queryParams.add('district=$district');
    
    if (queryParams.isNotEmpty) {
      endpoint += '?' + queryParams.join('&');
    }
    
    return await _apiService.get<List<Report>>(
      endpoint,
      (data) => List<Report>.from(
        (data as List).map((x) => Report.fromJson(x)),
      ),
    );
  }

  // Get reports created by current user
  Future<ApiResponse<List<Report>>> getMyReports() async {
    return await _apiService.get<List<Report>>(
      '/reports/me',
      (data) => List<Report>.from(
        (data as List).map((x) => Report.fromJson(x)),
      ),
    );
  }

  // Get a single report by ID
  Future<ApiResponse<Report>> getReportById(String reportId) async {
    return await _apiService.get<Report>(
      '/reports/$reportId',
      (data) => Report.fromJson(data),
    );
  }

  // Update a report
  Future<ApiResponse<Report>> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? category,
    String? address,
    String? district,
    String? state,
    String? pincode,
    Location? location,
  }) async {
    return await _apiService.put<Report>(
      '/reports/$reportId',
      {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (address != null) 'address': address,
        if (district != null) 'district': district,
        if (state != null) 'state': state,
        if (pincode != null) 'pincode': pincode,
        if (location != null) 'location': location.toJson(),
      },
      (data) => Report.fromJson(data),
    );
  }

  // Delete a report
  Future<ApiResponse<void>> deleteReport(String reportId) async {
    return await _apiService.delete<void>(
      '/reports/$reportId',
      null,
    );
  }

  // Add a comment to a report
  Future<ApiResponse<Comment>> addComment({
    required String reportId,
    required String text,
  }) async {
    return await _apiService.post<Comment>(
      '/reports/$reportId/comments',
      {'text': text},
      (data) => Comment.fromJson(data),
    );
  }

  // Update report status (for officers and volunteers)
  Future<ApiResponse<Report>> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    return await _apiService.put<Report>(
      '/reports/$reportId/status',
      {'status': status},
      (data) => Report.fromJson(data),
    );
  }

  // Assign a report to an officer (for admin)
  Future<ApiResponse<Report>> assignReportToOfficer({
    required String reportId,
    required String officerId,
  }) async {
    return await _apiService.put<Report>(
      '/reports/$reportId/assign',
      {'officerId': officerId},
      (data) => Report.fromJson(data),
    );
  }
}
