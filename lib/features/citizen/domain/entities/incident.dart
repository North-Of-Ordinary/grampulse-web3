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
      'address': address,
    };
  }
}

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final IncidentLocation location;
  final int severity; // Changed to int to match models
  final String? imageUrl;
  final DateTime createdAt;
  final String userId;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.severity,
    this.imageUrl,
    required this.createdAt,
    required this.userId,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'pending',
      location: json['location'] != null
          ? IncidentLocation.fromJson(json['location'])
          : const IncidentLocation(latitude: 0.0, longitude: 0.0),
      severity: json['severity'] ?? 1, // Changed to int
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'location': location.toJson(),
      'severity': severity,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }
}
