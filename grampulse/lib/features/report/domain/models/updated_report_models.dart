import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/app_text_styles.dart';
import 'package:grampulse/features/report/domain/models/report_models.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconCode;
  final bool isDisasterRelated;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    this.isDisasterRelated = false,
    this.color = Colors.blue,
  });

  /// List of default categories
  static List<CategoryModel> get defaultCategories => [
    CategoryModel(id: 'road', name: 'Roads', iconCode: '0xe3e7', color: Colors.brown), // Icons.road
    CategoryModel(id: 'water', name: 'Water', iconCode: '0xe798', color: Colors.blue), // Icons.water_drop
    CategoryModel(id: 'power', name: 'Power', iconCode: '0xe63c', color: Colors.amber), // Icons.power
    CategoryModel(id: 'sanitation', name: 'Sanitation', iconCode: '0xe57c', color: Colors.green), // Icons.cleaning_services
    CategoryModel(id: 'safety', name: 'Safety', iconCode: '0xe479', color: Colors.red), // Icons.health_and_safety
    CategoryModel(id: 'flood', name: 'Flood', iconCode: '0xe46a', isDisasterRelated: true, color: Colors.blueGrey), // Icons.flood
    CategoryModel(id: 'others', name: 'Others', iconCode: '0xe620', color: Colors.purple), // Icons.more_horiz
  ];
}

/// Type of media in a report
enum MediaType {
  image,
  video,
  audio,
  document,
}

/// Model representing media files that are captured/selected for an issue report
class ReportMedia {
  final String id;
  final File? file;
  final MediaType fileType;
  final DateTime capturedAt;
  final bool isUploaded;
  final String? url;
  final String? name;
  final File? thumbnailFile;
  final String? thumbnailUrl;

  const ReportMedia({
    required this.id,
    this.file,
    required this.fileType,
    required this.capturedAt,
    this.isUploaded = false,
    this.url,
    this.name,
    this.thumbnailFile,
    this.thumbnailUrl,
  });

  ReportMedia copyWith({
    String? id,
    File? file,
    MediaType? fileType,
    DateTime? capturedAt,
    bool? isUploaded,
    String? url,
    String? name,
    File? thumbnailFile,
    String? thumbnailUrl,
  }) {
    return ReportMedia(
      id: id ?? this.id,
      file: file ?? this.file,
      fileType: fileType ?? this.fileType,
      capturedAt: capturedAt ?? this.capturedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      url: url ?? this.url,
      name: name ?? this.name,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  /// Checks if the media is a video
  bool get isVideo => fileType == MediaType.video;

  /// Checks if the media is an image
  bool get isImage => fileType == MediaType.image;

  /// Checks if the media is an audio recording
  bool get isAudio => fileType == MediaType.audio;
  
  /// Checks if the media is a document
  bool get isDocument => fileType == MediaType.document;
}

/// Status of a relief request
enum ReliefRequestStatus {
  pending,
  approved,
  rejected,
  moreinfoRequired,
}

/// Bank details for relief request
class BankDetails {
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String? branch;

  const BankDetails({
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.branch,
  });

  BankDetails copyWith({
    String? accountHolder,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branch,
  }) {
    return BankDetails(
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      branch: branch ?? this.branch,
    );
  }

  /// Creates an empty bank details object
  static BankDetails empty() {
    return const BankDetails(
      accountHolder: '',
      accountNumber: '',
      ifscCode: '',
      bankName: '',
    );
  }
}

/// Model representing a relief request associated with an issue
class ReliefRequest {
  final String id;
  final String description;
  final double damageValue;
  final BankDetails bankDetails;
  final Map<String, File> documents;
  final ReliefRequestStatus status;
  final DateTime createdAt;
  final String? officerRemarks;

  const ReliefRequest({
    required this.id,
    required this.description,
    required this.damageValue,
    required this.bankDetails,
    this.documents = const {},
    this.status = ReliefRequestStatus.pending,
    required this.createdAt,
    this.officerRemarks,
  });

  ReliefRequest copyWith({
    String? id,
    String? description,
    double? damageValue,
    BankDetails? bankDetails,
    Map<String, File>? documents,
    ReliefRequestStatus? status,
    DateTime? createdAt,
    String? officerRemarks,
  }) {
    return ReliefRequest(
      id: id ?? this.id,
      description: description ?? this.description,
      damageValue: damageValue ?? this.damageValue,
      bankDetails: bankDetails ?? this.bankDetails,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      officerRemarks: officerRemarks ?? this.officerRemarks,
    );
  }

  /// Creates an empty relief request
  static ReliefRequest empty() {
    return ReliefRequest(
      id: '',
      description: '',
      damageValue: 0.0,
      bankDetails: BankDetails.empty(),
      documents: {},
      createdAt: DateTime.now(),
    );
  }
}

/// Model representing an issue reported by a citizen
class IssueModel {
  final String id;
  final String title;
  final String description;
  final CategoryModel category;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? address;
  final double latitude;
  final double longitude;
  final List<ReportMedia> media;
  final ReliefRequest? reliefRequest;
  final List<StatusUpdate>? statusUpdates;
  final String? assignedDepartment;
  final String? assignedOfficer;
  final DateTime? expectedResolutionDate;

  const IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.address,
    required this.latitude,
    required this.longitude,
    this.media = const [],
    this.reliefRequest,
    this.statusUpdates,
    this.assignedDepartment,
    this.assignedOfficer,
    this.expectedResolutionDate,
  });

  IssueModel copyWith({
    String? id,
    String? title,
    String? description,
    CategoryModel? category,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    double? latitude,
    double? longitude,
    List<ReportMedia>? media,
    ReliefRequest? reliefRequest,
    List<StatusUpdate>? statusUpdates,
    String? assignedDepartment,
    String? assignedOfficer,
    DateTime? expectedResolutionDate,
  }) {
    return IssueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      media: media ?? this.media,
      reliefRequest: reliefRequest ?? this.reliefRequest,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
      expectedResolutionDate: expectedResolutionDate ?? this.expectedResolutionDate,
    );
  }
}

/// Model representing a status update for an issue
class StatusUpdate {
  final String id;
  final String status;
  final DateTime timestamp;
  final String? details;
  final String? updatedBy;

  const StatusUpdate({
    required this.id,
    required this.status,
    required this.timestamp,
    this.details,
    this.updatedBy,
  });
}
