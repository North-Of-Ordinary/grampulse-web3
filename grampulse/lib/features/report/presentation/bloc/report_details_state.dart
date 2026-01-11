import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class ReportDetailsState extends Equatable {
  const ReportDetailsState();
  
  @override
  List<Object?> get props => [];
}

class DetailsInitial extends ReportDetailsState {
  const DetailsInitial();
}

class DetailsLoading extends ReportDetailsState {
  const DetailsLoading();
}

class DetailsLoaded extends ReportDetailsState {
  final IssueModel issue;
  final bool isSubmittingAction;
  
  const DetailsLoaded({
    required this.issue,
    this.isSubmittingAction = false,
  });
  
  @override
  List<Object?> get props => [issue, isSubmittingAction];
  
  DetailsLoaded copyWith({
    IssueModel? issue,
    bool? isSubmittingAction,
  }) {
    return DetailsLoaded(
      issue: issue ?? this.issue,
      isSubmittingAction: isSubmittingAction ?? this.isSubmittingAction,
    );
  }
}

class DetailsUpdating extends ReportDetailsState {
  final String message;
  
  const DetailsUpdating(this.message);
  
  @override
  List<Object> get props => [message];
}

class DetailsActionSuccess extends ReportDetailsState {
  final String message;
  final String action;
  
  const DetailsActionSuccess({
    required this.message,
    required this.action,
  });
  
  @override
  List<Object> get props => [message, action];
}

class DetailsError extends ReportDetailsState {
  final String message;
  
  const DetailsError(this.message);
  
  @override
  List<Object> get props => [message];
}
