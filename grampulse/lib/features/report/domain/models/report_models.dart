import 'dart:io';

/// Model representing media files that are captured/selected for an issue report
class ReportMedia {
  final String id;
  final File file;
  final MediaType type;
  final DateTime capturedAt;
  final bool isUploaded;
  final String? url;

  const ReportMedia({
    required this.id,
    required this.file,
    required this.type,
    required this.capturedAt,
    this.isUploaded = false,
    this.url,
  });

  ReportMedia copyWith({
    String? id,
    File? file,
    MediaType? type,
    DateTime? capturedAt,
    bool? isUploaded,
    String? url,
  }) {
    return ReportMedia(
      id: id ?? this.id,
      file: file ?? this.file,
      type: type ?? this.type,
      capturedAt: capturedAt ?? this.capturedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      url: url ?? this.url,
    );
  }

  /// Checks if the media is a video
  bool get isVideo => type == MediaType.video;

  /// Checks if the media is an image
  bool get isImage => type == MediaType.image;

  /// Checks if the media is an audio recording
  bool get isAudio => type == MediaType.audio;
}

/// Type of media in a report
enum MediaType {
  image,
  video,
  audio,
}

/// Model representing a relief request associated with an issue
class ReliefRequest {
  final String id;
  final String description;
  final double amountRequested;
  final BankDetails bankDetails;
  final Map<String, File> documents;
  final ReliefRequestStatus status;
  final DateTime createdAt;
  final String? officerRemarks;

  const ReliefRequest({
    required this.id,
    required this.description,
    required this.amountRequested,
    required this.bankDetails,
    required this.documents,
    required this.status,
    required this.createdAt,
    this.officerRemarks,
  });

  ReliefRequest copyWith({
    String? id,
    String? description,
    double? amountRequested,
    BankDetails? bankDetails,
    Map<String, File>? documents,
    ReliefRequestStatus? status,
    DateTime? createdAt,
    String? officerRemarks,
  }) {
    return ReliefRequest(
      id: id ?? this.id,
      description: description ?? this.description,
      amountRequested: amountRequested ?? this.amountRequested,
      bankDetails: bankDetails ?? this.bankDetails,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      officerRemarks: officerRemarks ?? this.officerRemarks,
    );
  }

  /// Creates an empty relief request
  factory ReliefRequest.empty() {
    return ReliefRequest(
      id: '',
      description: '',
      amountRequested: 0.0,
      bankDetails: BankDetails.empty(),
      documents: {},
      status: ReliefRequestStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}

/// Status of a relief request
enum ReliefRequestStatus {
  pending,
  approved,
  partiallyApproved,
  rejected,
  moreinfoRequired,
}

/// Bank details for relief request
class BankDetails {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String? bankName;
  final String? branch;

  const BankDetails({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    this.bankName,
    this.branch,
  });

  BankDetails copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branch,
  }) {
    return BankDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      branch: branch ?? this.branch,
    );
  }

  /// Creates empty bank details
  factory BankDetails.empty() {
    return const BankDetails(
      accountHolderName: '',
      accountNumber: '',
      ifscCode: '',
    );
  }
}

/// Model representing a category for issues
class CategoryModel {
  final String id;
  final String name;
  final String iconCode;
  final bool isDisasterRelated;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    this.isDisasterRelated = false,
  });

  /// List of default categories
  static List<CategoryModel> get defaultCategories => [
    CategoryModel(id: 'road', name: 'Roads', iconCode: '0xe3e7'), // Icons.road
    CategoryModel(id: 'water', name: 'Water', iconCode: '0xe798'), // Icons.water_drop
    CategoryModel(id: 'power', name: 'Power', iconCode: '0xe63c'), // Icons.power
    CategoryModel(id: 'sanitation', name: 'Sanitation', iconCode: '0xe57c'), // Icons.cleaning_services
    CategoryModel(id: 'safety', name: 'Safety', iconCode: '0xe479'), // Icons.health_and_safety
    CategoryModel(id: 'flood', name: 'Flood', iconCode: '0xe46a', isDisasterRelated: true), // Icons.flood
    CategoryModel(id: 'others', name: 'Others', iconCode: '0xe620'), // Icons.more_horiz
  ];
}
