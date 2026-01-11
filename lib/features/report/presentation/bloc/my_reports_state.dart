import 'package:equatable/equatable.dart';

abstract class MyReportsState extends Equatable {
  const MyReportsState();
  
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends MyReportsState {
  const ReportsInitial();
}

class ReportsLoading extends MyReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends MyReportsState {
  final List<dynamic> reports;
  final String selectedStatus;
  final bool hasMore;
  
  const ReportsLoaded({
    required this.reports,
    this.selectedStatus = 'all',
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [reports, selectedStatus, hasMore];
  
  ReportsLoaded copyWith({
    List<dynamic>? reports,
    String? selectedStatus,
    bool? hasMore,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ReportsEmpty extends MyReportsState {
  const ReportsEmpty();
}

class ReportsError extends MyReportsState {
  final String message;
  
  const ReportsError(this.message);
  
  @override
  List<Object> get props => [message];
}
