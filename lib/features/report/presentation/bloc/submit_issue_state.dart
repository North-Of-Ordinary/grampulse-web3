import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class SubmitIssueState extends Equatable {
  const SubmitIssueState();

  @override
  List<Object?> get props => [];
}

class SubmitInitial extends SubmitIssueState {
  const SubmitInitial();
}

class SubmitValidating extends SubmitIssueState {
  const SubmitValidating();
}

class SubmitUploading extends SubmitIssueState {
  final int progress;
  final int total;

  const SubmitUploading({
    required this.progress,
    required this.total,
  });

  double get progressPercentage => total > 0 ? progress / total : 0.0;

  @override
  List<Object?> get props => [progress, total];
}

class SubmitSuccess extends SubmitIssueState {
  final String issueId;
  final DateTime submittedAt;

  const SubmitSuccess({
    required this.issueId,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [issueId, submittedAt];
}

class SubmitOfflineQueued extends SubmitIssueState {
  final String queuedId;

  const SubmitOfflineQueued({
    required this.queuedId,
  });

  @override
  List<Object?> get props => [queuedId];
}

class SubmitError extends SubmitIssueState {
  final String message;

  const SubmitError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubmitReady extends SubmitIssueState {
  final List<ReportMedia> media;
  final CategoryModel category;
  final String description;
  final int severity;
  final double latitude;
  final double longitude;
  final String address;
  final ReliefRequest? reliefRequest;
  final bool isOnline;

  const SubmitReady({
    required this.media,
    required this.category,
    required this.description,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.reliefRequest,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [
    media,
    category,
    description,
    severity,
    latitude,
    longitude,
    address,
    reliefRequest,
    isOnline,
  ];

  SubmitReady copyWith({
    List<ReportMedia>? media,
    CategoryModel? category,
    String? description,
    int? severity,
    double? latitude,
    double? longitude,
    String? address,
    ReliefRequest? reliefRequest,
    bool? isOnline,
  }) {
    return SubmitReady(
      media: media ?? this.media,
      category: category ?? this.category,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      reliefRequest: reliefRequest ?? this.reliefRequest,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
