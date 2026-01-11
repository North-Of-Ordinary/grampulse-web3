import 'package:equatable/equatable.dart';

abstract class MyReportsEvent extends Equatable {
  const MyReportsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadMyReports extends MyReportsEvent {
  final bool refresh;
  
  const LoadMyReports({this.refresh = false});
  
  @override
  List<Object?> get props => [refresh];
}

class FilterByStatus extends MyReportsEvent {
  final String status;
  
  const FilterByStatus(this.status);
  
  @override
  List<Object> get props => [status];
}

class LoadMoreReports extends MyReportsEvent {
  const LoadMoreReports();
}

class RefreshReports extends MyReportsEvent {
  const RefreshReports();
}
