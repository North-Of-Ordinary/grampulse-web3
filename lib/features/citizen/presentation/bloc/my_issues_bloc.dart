import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'my_issues_event.dart';
part 'my_issues_state.dart';

class MyIssuesBloc extends Bloc<MyIssuesEvent, MyIssuesState> {
  // Repositories would be injected here in real implementation
  // final IssueRepository issueRepository;

  MyIssuesBloc() : super(MyIssuesInitial()) {
    on<LoadMyIssuesEvent>(_onLoadMyIssues);
    on<FilterMyIssuesEvent>(_onFilterMyIssues);
  }

  FutureOr<void> _onLoadMyIssues(
    LoadMyIssuesEvent event,
    Emitter<MyIssuesState> emit,
  ) async {
    emit(MyIssuesLoading());
    
    try {
      // Simulate delay for API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, we would get data from repositories
      final myIssues = _getMockMyIssues();
      
      emit(MyIssuesLoaded(
        issues: myIssues,
        filter: 'all',
      ));
    } catch (e) {
      emit(MyIssuesError(message: e.toString()));
    }
  }

  FutureOr<void> _onFilterMyIssues(
    FilterMyIssuesEvent event,
    Emitter<MyIssuesState> emit,
  ) async {
    if (state is MyIssuesLoaded) {
      final currentState = state as MyIssuesLoaded;
      
      // Get all issues first
      final allIssues = _getMockMyIssues();
      
      // Filter issues based on status
      final filteredIssues = event.filter == 'all'
          ? allIssues
          : allIssues.where((issue) => issue['status'] == event.filter).toList();
      
      emit(currentState.copyWith(
        issues: filteredIssues,
        filter: event.filter,
      ));
    }
  }

  // Mock data for development
  List<Map<String, dynamic>> _getMockMyIssues() {
    return [
      {
        'id': '101',
        'title': 'Garbage Not Collected',
        'description': 'Garbage not collected for a week',
        'category': 'Sanitation',
        'categoryIcon': 'sanitation',
        'status': 'in_progress',
        'location': 'My Home Area',
        'createdAt': DateTime.now().subtract(const Duration(days: 7)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 3)),
        'assignedTo': 'Sanitation Department',
      },
      {
        'id': '102',
        'title': 'Damaged Park Bench',
        'description': 'Bench in community park is broken',
        'category': 'Public Property',
        'categoryIcon': 'property',
        'status': 'resolved',
        'location': 'Community Park',
        'createdAt': DateTime.now().subtract(const Duration(days: 14)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
        'assignedTo': 'Parks Department',
        'resolutionComment': 'Bench has been replaced with a new one',
      },
      {
        'id': '103',
        'title': 'Stray Dogs Issue',
        'description': 'Aggressive stray dogs in the colony',
        'category': 'Safety',
        'categoryIcon': 'safety',
        'status': 'new',
        'location': 'Near School Road',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '104',
        'title': 'Water Supply Irregular',
        'description': 'Water supply is irregular for past week',
        'category': 'Water',
        'categoryIcon': 'water',
        'status': 'overdue',
        'location': 'Entire Colony',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 20)),
        'assignedTo': 'Water Department',
      },
      {
        'id': '105',
        'title': 'Bridge Needs Repair',
        'description': 'Small bridge over canal has cracks',
        'category': 'Infrastructure',
        'categoryIcon': 'infrastructure',
        'status': 'verified',
        'location': 'Canal Road',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 8)),
        'assignedTo': 'Public Works Department',
        'verifiedBy': 'Village Engineer',
      },
    ];
  }
}
