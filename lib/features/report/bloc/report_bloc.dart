import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/report_service.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllReports extends ReportEvent {
  final String? status;
  final String? category;
  final String? district;

  const LoadAllReports({this.status, this.category, this.district});

  @override
  List<Object?> get props => [status, category, district];
}

class LoadMyReports extends ReportEvent {}

class LoadReportDetails extends ReportEvent {
  final String reportId;

  const LoadReportDetails(this.reportId);

  @override
  List<Object> get props => [reportId];
}

class CreateReport extends ReportEvent {
  final String title;
  final String description;
  final String category;
  final String address;
  final String district;
  final String state;
  final String pincode;
  final Location? location;
  final List<File>? images;

  const CreateReport({
    required this.title,
    required this.description,
    required this.category,
    required this.address,
    required this.district,
    required this.state,
    required this.pincode,
    this.location,
    this.images,
  });

  @override
  List<Object?> get props => [
    title, 
    description, 
    category, 
    address, 
    district, 
    state, 
    pincode, 
    location, 
    images
  ];
}

class UpdateReport extends ReportEvent {
  final String reportId;
  final String? title;
  final String? description;
  final String? category;
  final String? address;
  final String? district;
  final String? state;
  final String? pincode;
  final Location? location;

  const UpdateReport({
    required this.reportId,
    this.title,
    this.description,
    this.category,
    this.address,
    this.district,
    this.state,
    this.pincode,
    this.location,
  });

  @override
  List<Object?> get props => [
    reportId, 
    title, 
    description, 
    category, 
    address, 
    district, 
    state, 
    pincode, 
    location
  ];
}

class DeleteReport extends ReportEvent {
  final String reportId;

  const DeleteReport(this.reportId);

  @override
  List<Object> get props => [reportId];
}

class AddComment extends ReportEvent {
  final String reportId;
  final String text;

  const AddComment({
    required this.reportId,
    required this.text,
  });

  @override
  List<Object> get props => [reportId, text];
}

class UpdateReportStatus extends ReportEvent {
  final String reportId;
  final String status;

  const UpdateReportStatus({
    required this.reportId,
    required this.status,
  });

  @override
  List<Object> get props => [reportId, status];
}

class AssignReportToOfficer extends ReportEvent {
  final String reportId;
  final String officerId;

  const AssignReportToOfficer({
    required this.reportId,
    required this.officerId,
  });

  @override
  List<Object> get props => [reportId, officerId];
}

// States
abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<Report> reports;

  const ReportsLoaded(this.reports);

  @override
  List<Object> get props => [reports];
}

class MyReportsLoaded extends ReportState {
  final List<Report> reports;

  const MyReportsLoaded(this.reports);

  @override
  List<Object> get props => [reports];
}

class ReportDetailsLoaded extends ReportState {
  final Report report;

  const ReportDetailsLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class ReportCreated extends ReportState {
  final Report report;

  const ReportCreated(this.report);

  @override
  List<Object> get props => [report];
}

class ReportUpdated extends ReportState {
  final Report report;

  const ReportUpdated(this.report);

  @override
  List<Object> get props => [report];
}

class ReportDeleted extends ReportState {}

class CommentAdded extends ReportState {
  final Comment comment;

  const CommentAdded(this.comment);

  @override
  List<Object> get props => [comment];
}

class ReportStatusUpdated extends ReportState {
  final Report report;

  const ReportStatusUpdated(this.report);

  @override
  List<Object> get props => [report];
}

class ReportAssigned extends ReportState {
  final Report report;

  const ReportAssigned(this.report);

  @override
  List<Object> get props => [report];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportService _reportService = ReportService();
  
  ReportBloc() : super(ReportInitial()) {
    on<LoadAllReports>(_onLoadAllReports);
    on<LoadMyReports>(_onLoadMyReports);
    on<LoadReportDetails>(_onLoadReportDetails);
    on<CreateReport>(_onCreateReport);
    on<UpdateReport>(_onUpdateReport);
    on<DeleteReport>(_onDeleteReport);
    on<AddComment>(_onAddComment);
    on<UpdateReportStatus>(_onUpdateReportStatus);
    on<AssignReportToOfficer>(_onAssignReportToOfficer);
  }

  Future<void> _onLoadAllReports(
    LoadAllReports event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.getAllReports(
        status: event.status,
        category: event.category,
        district: event.district,
      );
      
      if (response.success && response.data != null) {
        emit(ReportsLoaded(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onLoadMyReports(
    LoadMyReports event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.getMyReports();
      
      if (response.success && response.data != null) {
        emit(MyReportsLoaded(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onLoadReportDetails(
    LoadReportDetails event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.getReportById(event.reportId);
      
      if (response.success && response.data != null) {
        emit(ReportDetailsLoaded(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onCreateReport(
    CreateReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.createReport(
        title: event.title,
        description: event.description,
        category: event.category,
        address: event.address,
        district: event.district,
        state: event.state,
        pincode: event.pincode,
        location: event.location,
        images: event.images,
      );
      
      if (response.success && response.data != null) {
        emit(ReportCreated(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onUpdateReport(
    UpdateReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.updateReport(
        reportId: event.reportId,
        title: event.title,
        description: event.description,
        category: event.category,
        address: event.address,
        district: event.district,
        state: event.state,
        pincode: event.pincode,
        location: event.location,
      );
      
      if (response.success && response.data != null) {
        emit(ReportUpdated(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onDeleteReport(
    DeleteReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.deleteReport(event.reportId);
      
      if (response.success) {
        emit(ReportDeleted());
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final response = await _reportService.addComment(
        reportId: event.reportId,
        text: event.text,
      );
      
      if (response.success && response.data != null) {
        emit(CommentAdded(response.data!));
        
        // Reload report details to get updated comments list
        add(LoadReportDetails(event.reportId));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onUpdateReportStatus(
    UpdateReportStatus event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.updateReportStatus(
        reportId: event.reportId,
        status: event.status,
      );
      
      if (response.success && response.data != null) {
        emit(ReportStatusUpdated(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onAssignReportToOfficer(
    AssignReportToOfficer event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final response = await _reportService.assignReportToOfficer(
        reportId: event.reportId,
        officerId: event.officerId,
      );
      
      if (response.success && response.data != null) {
        emit(ReportAssigned(response.data!));
      } else {
        emit(ReportError(response.message));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
