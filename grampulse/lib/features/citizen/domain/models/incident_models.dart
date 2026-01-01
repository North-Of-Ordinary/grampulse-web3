class IncidentCategory {
  final String id;
  final String name;
  final String description;
  final String icon;

  const IncidentCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory IncidentCategory.fromJson(Map<String, dynamic> json) {
    return IncidentCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? json['name'] ?? '', // Use name as fallback for description
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}

class IncidentLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const IncidentLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory IncidentLocation.fromJson(Map<String, dynamic> json) {
    return IncidentLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }
}

class IncidentUser {
  final String id;
  final String? name;
  final String? phone;

  const IncidentUser({
    required this.id,
    this.name,
    this.phone,
  });

  factory IncidentUser.fromJson(Map<String, dynamic> json) {
    return IncidentUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'],
      phone: json['phone'],
    );
  }
}

class Incident {
  final String id;
  final IncidentUser user;
  final String categoryId;
  final String title;
  final String description;
  final IncidentLocation location;
  final int severity; // 1: Low, 2: Medium, 3: High
  final String status;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Incident({
    required this.id,
    required this.user,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.location,
    required this.severity,
    required this.status,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['_id'] ?? json['id'] ?? '',
      user: IncidentUser.fromJson(json['user'] ?? {}),
      categoryId: json['categoryId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: IncidentLocation.fromJson(json['location'] ?? {}),
      severity: json['severity'] ?? 1,
      status: json['status'] ?? 'NEW',
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get severityText {
    switch (severity) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Low';
    }
  }

  String get statusText {
    switch (status) {
      case 'NEW':
        return 'New';
      case 'VERIFIED':
        return 'Verified';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      case 'CLOSED':
        return 'Closed';
      default:
        return status;
    }
  }
}

class IncidentStatistics {
  final int newIncidents;
  final int inProgress;
  final int resolved;
  final int myIncidents;

  const IncidentStatistics({
    required this.newIncidents,
    required this.inProgress,
    required this.resolved,
    required this.myIncidents,
  });

  factory IncidentStatistics.fromJson(Map<String, dynamic> json) {
    return IncidentStatistics(
      newIncidents: json['newIncidents'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      resolved: json['resolved'] ?? 0,
      myIncidents: json['myIncidents'] ?? 0,
    );
  }

  int get total => newIncidents + inProgress + resolved;
}
