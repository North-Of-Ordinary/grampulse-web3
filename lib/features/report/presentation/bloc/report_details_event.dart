import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class ReportDetailsEvent extends Equatable {
  const ReportDetailsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadReportDetails extends ReportDetailsEvent {
  final String reportId;
  
  const LoadReportDetails(this.reportId);
  
  @override
  List<Object> get props => [reportId];
}

class RefreshReportDetails extends ReportDetailsEvent {
  const RefreshReportDetails();
}

class ConfirmResolution extends ReportDetailsEvent {
  final int rating;
  final String feedback;
  
  const ConfirmResolution({
    required this.rating,
    required this.feedback,
  });
  
  @override
  List<Object> get props => [rating, feedback];
}

class ReopenIssue extends ReportDetailsEvent {
  final String reason;
  
  const ReopenIssue(this.reason);
  
  @override
  List<Object> get props => [reason];
}

class RequestUpdate extends ReportDetailsEvent {
  final String message;
  
  const RequestUpdate(this.message);
  
  @override
  List<Object> get props => [message];
}

class CancelReport extends ReportDetailsEvent {
  final String reason;
  
  const CancelReport(this.reason);
  
  @override
  List<Object> get props => [reason];
}

class ShareReport extends ReportDetailsEvent {
  const ShareReport();
}
