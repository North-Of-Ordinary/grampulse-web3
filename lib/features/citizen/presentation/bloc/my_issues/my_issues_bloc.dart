import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/issue_model.dart';
part 'my_issues_event.dart';
part 'my_issues_state.dart';

class MyIssuesBloc extends Bloc<MyIssuesEvent, MyIssuesState> {
  MyIssuesBloc() : super(MyIssuesInitial()) {
    on<LoadMyIssues>(_onLoadMyIssues);
    on<RefreshMyIssues>(_onRefreshMyIssues);
    on<FilterMyIssues>(_onFilterMyIssues);
  }

  Future<void> _onLoadMyIssues(
    LoadMyIssues event,
    Emitter<MyIssuesState> emit,
  ) async {
    try {
      emit(MyIssuesLoading());
      
      // Here we would fetch data from repositories
      // For now we'll use mock data
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data for user's issues
      final mockIssues = _getMockIssues();
      
      emit(MyIssuesLoaded(
        reportedIssues: mockIssues.where((i) => i.reporterId == 'user123').toList(),
        upvotedIssues: mockIssues.where((i) => i.id == '2').toList(),
      ));
    } catch (error) {
      emit(MyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onRefreshMyIssues(
    RefreshMyIssues event,
    Emitter<MyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is MyIssuesLoaded) {
        emit(MyIssuesRefreshing(
          reportedIssues: currentState.reportedIssues,
          upvotedIssues: currentState.upvotedIssues,
        ));
        
        // Here we would re-fetch data from repositories
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Mock data for user's issues
        final mockIssues = _getMockIssues();
        
        emit(MyIssuesLoaded(
          reportedIssues: mockIssues.where((i) => i.reporterId == 'user123').toList(),
          upvotedIssues: mockIssues.where((i) => i.id == '2').toList(),
        ));
      }
    } catch (error) {
      emit(MyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onFilterMyIssues(
    FilterMyIssues event,
    Emitter<MyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is MyIssuesLoaded) {
        emit(MyIssuesLoading());
        
        // Here we would apply filters to the data
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock data for issues
        final mockIssues = _getMockIssues();
        
        // Filter based on status and category if provided
        final filteredReported = mockIssues
            .where((i) => i.reporterId == 'user123')
            .where((issue) {
              if (event.statusFilter != null && 
                  issue.status != event.statusFilter) {
                return false;
              }
              
              if (event.categoryFilter != null && 
                  issue.category != event.categoryFilter) {
                return false;
              }
              
              return true;
            })
            .toList();
            
        final filteredUpvoted = mockIssues
            .where((i) => i.id == '2')
            .where((issue) {
              if (event.statusFilter != null && 
                  issue.status != event.statusFilter) {
                return false;
              }
              
              if (event.categoryFilter != null && 
                  issue.category != event.categoryFilter) {
                return false;
              }
              
              return true;
            })
            .toList();
        
        emit(MyIssuesLoaded(
          reportedIssues: filteredReported,
          upvotedIssues: filteredUpvoted,
          activeFilters: {
            if (event.categoryFilter != null)
              'category': event.categoryFilter,
            if (event.statusFilter != null)
              'status': event.statusFilter,
          },
        ));
      }
    } catch (error) {
      emit(MyIssuesError(message: error.toString()));
    }
  }
  
  // Helper to create mock issues
  List<Issue> _getMockIssues() {
    final now = DateTime.now();
    
    return [
      Issue(
        id: '1',
        title: 'Broken street light near community center',
        description: 'The street light has been broken for over a week, making it unsafe at night.',
        category: IssueCategory.electricity,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        status: IssueStatus.in_progress,
        priority: IssuePriority.medium,
        location: GeoLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          address: 'Near Community Center, Main Road',
          locality: 'Andheri',
          adminArea: 'Mumbai',
          pinCode: '400053',
        ),
        reporterId: 'user123',
        reporterName: 'Rahul Sharma',
        mediaUrls: ['https://example.com/image1.jpg'],
        upvotes: 5,
        adminLevel: AdminLevel.panchayat,
        assignedDepartment: 'Electricity Department',
        isPublic: true,
        updates: [
          IssueUpdate(
            id: 'update1',
            timestamp: now.subtract(const Duration(days: 2)),
            comment: 'Issue has been assigned to the electricity department',
            previousStatus: IssueStatus.new_issue,
            newStatus: IssueStatus.in_progress,
            updatedBy: 'admin1',
            updaterName: 'Admin User',
            updaterRole: 'Panchayat Officer',
            mediaUrls: [],
          ),
        ],
      ),
      Issue(
        id: '4',
        title: 'Pothole on Main Street',
        description: 'Large pothole causing accidents and damage to vehicles.',
        category: IssueCategory.roadDamage,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
        status: IssueStatus.new_issue,
        priority: IssuePriority.high,
        location: GeoLocation(
          latitude: 19.0770,
          longitude: 72.8787,
          address: 'Main Street, Near Bus Stop',
          locality: 'Dadar',
          adminArea: 'Mumbai',
          pinCode: '400014',
        ),
        reporterId: 'user123',
        reporterName: 'Rahul Sharma',
        mediaUrls: ['https://example.com/image5.jpg'],
        upvotes: 15,
        adminLevel: AdminLevel.block,
        assignedDepartment: 'Road Department',
        isPublic: true,
        updates: [],
      ),
      Issue(
        id: '2',
        title: 'Water supply issue in North Block',
        description: 'We have been experiencing low water pressure for the past 3 days.',
        category: IssueCategory.waterSupply,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        status: IssueStatus.new_issue,
        priority: IssuePriority.high,
        location: GeoLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          address: 'North Block, Gandhi Road',
          locality: 'Borivali',
          adminArea: 'Mumbai',
          pinCode: '400091',
        ),
        reporterId: 'user456',
        reporterName: 'Priya Patel',
        mediaUrls: [],
        upvotes: 12,
        adminLevel: AdminLevel.block,
        assignedDepartment: 'Water Department',
        isPublic: true,
        updates: [],
      ),
    ];
  }
}
