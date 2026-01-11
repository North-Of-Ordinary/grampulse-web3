import 'package:equatable/equatable.dart';

abstract class DescribeIssueEvent extends Equatable {
  const DescribeIssueEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends DescribeIssueEvent {
  const LoadCategories();
}

class UpdateCategory extends DescribeIssueEvent {
  final String categoryId;

  const UpdateCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class UpdateDescription extends DescribeIssueEvent {
  final String description;

  const UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdateSeverity extends DescribeIssueEvent {
  final int severity;

  const UpdateSeverity(this.severity);

  @override
  List<Object?> get props => [severity];
}

class UpdateLocation extends DescribeIssueEvent {
  final double latitude;
  final double longitude;
  final String address;

  const UpdateLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

class ConvertVoiceToText extends DescribeIssueEvent {
  final String audioFilePath;
  final String targetLanguage;

  const ConvertVoiceToText({
    required this.audioFilePath,
    this.targetLanguage = 'en-US',
  });

  @override
  List<Object?> get props => [audioFilePath, targetLanguage];
}

class ValidateAndProceed extends DescribeIssueEvent {
  const ValidateAndProceed();
}
