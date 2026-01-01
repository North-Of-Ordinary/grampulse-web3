import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

enum SectionType { media, location, category, description, relief }

abstract class SubmitIssueEvent extends Equatable {
  const SubmitIssueEvent();

  @override
  List<Object?> get props => [];
}

class CheckConnection extends SubmitIssueEvent {
  const CheckConnection();
}

class SubmitIssue extends SubmitIssueEvent {
  const SubmitIssue();
}

class EditSection extends SubmitIssueEvent {
  final SectionType sectionType;

  const EditSection({required this.sectionType});

  @override
  List<Object?> get props => [sectionType];
}

class CancelSubmission extends SubmitIssueEvent {
  const CancelSubmission();
}
