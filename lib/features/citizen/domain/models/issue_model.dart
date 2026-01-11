import 'package:equatable/equatable.dart';

/// Status of a reported issue in the system
enum IssueStatus {
  new_issue,
  in_progress,
  resolved,
  overdue,
  verified,
}

/// Priority level of a reported issue
enum IssuePriority {
  low,
  medium,
  high,
  critical,
}

/// Category of an issue report
enum IssueCategory {
  roadDamage,
  waterSupply,
  electricity,
  sanitation,
  publicProperty,
  education,
  healthcare,
  other,
}

/// Administrative level to which the issue is assigned
enum AdminLevel {
  panchayat,
  block,
  district,
  state,
}

/// Represents a civic issue reported by a citizen
class Issue extends Equatable {
  final String id;
  final String title;
  final String description;
  final IssueCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final IssueStatus status;
  final IssuePriority priority;
  final GeoLocation location;
  final String reporterId;
  final String reporterName;
  final List<String> mediaUrls;
  final int upvotes;
  final AdminLevel adminLevel;
  final String assignedDepartment;
  final String? assignedOfficerId;
  final bool isPublic;
  final List<IssueUpdate> updates;
  final bool isOfflineOnly;
  final String? syncStatus; // null = synced, otherwise contains error or pending status

  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.priority,
    required this.location,
    required this.reporterId,
    required this.reporterName,
    required this.mediaUrls,
    required this.upvotes,
    required this.adminLevel,
    required this.assignedDepartment,
    this.assignedOfficerId,
    required this.isPublic,
    required this.updates,
    this.isOfflineOnly = false,
    this.syncStatus,
  });

  /// Creates a copy of this issue with the given fields replaced with new values
  Issue copyWith({
    String? id,
    String? title,
    String? description,
    IssueCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    IssueStatus? status,
    IssuePriority? priority,
    GeoLocation? location,
    String? reporterId,
    String? reporterName,
    List<String>? mediaUrls,
    int? upvotes,
    AdminLevel? adminLevel,
    String? assignedDepartment,
    String? assignedOfficerId,
    bool? isPublic,
    List<IssueUpdate>? updates,
    bool? isOfflineOnly,
    String? syncStatus,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      upvotes: upvotes ?? this.upvotes,
      adminLevel: adminLevel ?? this.adminLevel,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      isPublic: isPublic ?? this.isPublic,
      updates: updates ?? this.updates,
      isOfflineOnly: isOfflineOnly ?? this.isOfflineOnly,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Static method to create an empty issue with default values
  factory Issue.empty() {
    return Issue(
      id: '',
      title: '',
      description: '',
      category: IssueCategory.other,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: IssueStatus.new_issue,
      priority: IssuePriority.medium,
      location: GeoLocation.empty(),
      reporterId: '',
      reporterName: '',
      mediaUrls: const [],
      upvotes: 0,
      adminLevel: AdminLevel.panchayat,
      assignedDepartment: '',
      isPublic: true,
      updates: const [],
      isOfflineOnly: true,
    );
  }

  /// Creates a new issue from a map (e.g., from JSON)
  factory Issue.fromMap(Map<String, dynamic> map) {
    return Issue(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: IssueCategory.values.firstWhere(
        (e) => e.toString() == 'IssueCategory.${map['category']}',
        orElse: () => IssueCategory.other,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      status: IssueStatus.values.firstWhere(
        (e) => e.toString() == 'IssueStatus.${map['status']}',
        orElse: () => IssueStatus.new_issue,
      ),
      priority: IssuePriority.values.firstWhere(
        (e) => e.toString() == 'IssuePriority.${map['priority']}',
        orElse: () => IssuePriority.medium,
      ),
      location: GeoLocation.fromMap(map['location']),
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      upvotes: map['upvotes'] ?? 0,
      adminLevel: AdminLevel.values.firstWhere(
        (e) => e.toString() == 'AdminLevel.${map['adminLevel']}',
        orElse: () => AdminLevel.panchayat,
      ),
      assignedDepartment: map['assignedDepartment'] ?? '',
      assignedOfficerId: map['assignedOfficerId'],
      isPublic: map['isPublic'] ?? true,
      updates: (map['updates'] as List?)
          ?.map((update) => IssueUpdate.fromMap(update))
          .toList() ??
          [],
      isOfflineOnly: map['isOfflineOnly'] ?? false,
      syncStatus: map['syncStatus'],
    );
  }

  /// Converts this issue to a map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'location': location.toMap(),
      'reporterId': reporterId,
      'reporterName': reporterName,
      'mediaUrls': mediaUrls,
      'upvotes': upvotes,
      'adminLevel': adminLevel.toString().split('.').last,
      'assignedDepartment': assignedDepartment,
      'assignedOfficerId': assignedOfficerId,
      'isPublic': isPublic,
      'updates': updates.map((update) => update.toMap()).toList(),
      'isOfflineOnly': isOfflineOnly,
      'syncStatus': syncStatus,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        createdAt,
        updatedAt,
        status,
        priority,
        location,
        reporterId,
        reporterName,
        mediaUrls,
        upvotes,
        adminLevel,
        assignedDepartment,
        assignedOfficerId,
        isPublic,
        updates,
        isOfflineOnly,
        syncStatus,
      ];
}

/// Represents an update to an issue, such as status changes or comments
class IssueUpdate extends Equatable {
  final String id;
  final DateTime timestamp;
  final String comment;
  final IssueStatus? previousStatus;
  final IssueStatus? newStatus;
  final String updatedBy;
  final String updaterName;
  final String? updaterRole;
  final List<String> mediaUrls;

  const IssueUpdate({
    required this.id,
    required this.timestamp,
    required this.comment,
    this.previousStatus,
    this.newStatus,
    required this.updatedBy,
    required this.updaterName,
    this.updaterRole,
    required this.mediaUrls,
  });

  /// Creates a copy of this issue update with the given fields replaced with new values
  IssueUpdate copyWith({
    String? id,
    DateTime? timestamp,
    String? comment,
    IssueStatus? previousStatus,
    IssueStatus? newStatus,
    String? updatedBy,
    String? updaterName,
    String? updaterRole,
    List<String>? mediaUrls,
  }) {
    return IssueUpdate(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      comment: comment ?? this.comment,
      previousStatus: previousStatus ?? this.previousStatus,
      newStatus: newStatus ?? this.newStatus,
      updatedBy: updatedBy ?? this.updatedBy,
      updaterName: updaterName ?? this.updaterName,
      updaterRole: updaterRole ?? this.updaterRole,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }

  /// Creates a new issue update from a map (e.g., from JSON)
  factory IssueUpdate.fromMap(Map<String, dynamic> map) {
    return IssueUpdate(
      id: map['id'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      comment: map['comment'] ?? '',
      previousStatus: map['previousStatus'] != null
          ? IssueStatus.values.firstWhere(
              (e) => e.toString() == 'IssueStatus.${map['previousStatus']}',
              orElse: () => IssueStatus.new_issue)
          : null,
      newStatus: map['newStatus'] != null
          ? IssueStatus.values.firstWhere(
              (e) => e.toString() == 'IssueStatus.${map['newStatus']}',
              orElse: () => IssueStatus.new_issue)
          : null,
      updatedBy: map['updatedBy'] ?? '',
      updaterName: map['updaterName'] ?? '',
      updaterRole: map['updaterRole'],
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
    );
  }

  /// Converts this issue update to a map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'comment': comment,
      'previousStatus': previousStatus?.toString().split('.').last,
      'newStatus': newStatus?.toString().split('.').last,
      'updatedBy': updatedBy,
      'updaterName': updaterName,
      'updaterRole': updaterRole,
      'mediaUrls': mediaUrls,
    };
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        comment,
        previousStatus,
        newStatus,
        updatedBy,
        updaterName,
        updaterRole,
        mediaUrls,
      ];
}

/// Represents a geographic location with latitude, longitude, and address information
class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? locality;
  final String? adminArea;
  final String? pinCode;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.locality,
    this.adminArea,
    this.pinCode,
  });

  /// Creates an empty location with default values
  factory GeoLocation.empty() {
    return const GeoLocation(
      latitude: 0,
      longitude: 0,
    );
  }

  /// Creates a copy of this location with the given fields replaced with new values
  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? locality,
    String? adminArea,
    String? pinCode,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      locality: locality ?? this.locality,
      adminArea: adminArea ?? this.adminArea,
      pinCode: pinCode ?? this.pinCode,
    );
  }

  /// Creates a new location from a map (e.g., from JSON)
  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'],
      locality: map['locality'],
      adminArea: map['adminArea'],
      pinCode: map['pinCode'],
    );
  }

  /// Converts this location to a map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'locality': locality,
      'adminArea': adminArea,
      'pinCode': pinCode,
    };
  }

  /// Returns a formatted address string
  String getFormattedAddress() {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (locality != null && locality!.isNotEmpty) parts.add(locality!);
    if (adminArea != null && adminArea!.isNotEmpty) parts.add(adminArea!);
    if (pinCode != null && pinCode!.isNotEmpty) parts.add(pinCode!);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }
  
  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        locality,
        adminArea,
        pinCode,
      ];
}
