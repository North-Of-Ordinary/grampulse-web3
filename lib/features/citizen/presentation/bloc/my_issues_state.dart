part of 'my_issues_bloc.dart';

abstract class MyIssuesState extends Equatable {
  const MyIssuesState();
  
  @override
  List<Object?> get props => [];
}

class MyIssuesInitial extends MyIssuesState {}

class MyIssuesLoading extends MyIssuesState {}

class MyIssuesLoaded extends MyIssuesState {
  final List<Map<String, dynamic>> issues;
  final String filter; // 'all', 'new', 'in_progress', 'resolved', 'overdue', 'verified'

  const MyIssuesLoaded({
    required this.issues,
    required this.filter,
  });

  MyIssuesLoaded copyWith({
    List<Map<String, dynamic>>? issues,
    String? filter,
  }) {
    return MyIssuesLoaded(
      issues: issues ?? this.issues,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [issues, filter];
}

class MyIssuesError extends MyIssuesState {
  final String message;

  const MyIssuesError({required this.message});

  @override
  List<Object?> get props => [message];
}
