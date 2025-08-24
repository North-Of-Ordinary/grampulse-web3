part of 'my_issues_bloc.dart';

abstract class MyIssuesEvent extends Equatable {
  const MyIssuesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyIssuesEvent extends MyIssuesEvent {}

class FilterMyIssuesEvent extends MyIssuesEvent {
  final String filter; // 'all', 'new', 'in_progress', 'resolved', 'overdue', 'verified'

  const FilterMyIssuesEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}
