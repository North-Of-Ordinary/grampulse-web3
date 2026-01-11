import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/models/issue_model.dart';

part 'nearby_issues_event.dart';
part 'nearby_issues_state.dart';

class NearbyIssuesBloc extends Bloc<NearbyIssuesEvent, NearbyIssuesState> {
  NearbyIssuesBloc() : super(NearbyIssuesInitial()) {
    on<LoadNearbyIssues>(_onLoadNearbyIssues);
    on<RefreshNearbyIssues>(_onRefreshNearbyIssues);
    on<UpdateLocation>(_onUpdateLocation);
    on<FilterNearbyIssues>(_onFilterNearbyIssues);
  }

  Future<void> _onLoadNearbyIssues(
    LoadNearbyIssues event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      emit(NearbyIssuesLoading());
      
      // Here we would fetch data from repositories
      // For now we'll use mock data
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data for issues
      final mockIssues = _getMockIssues();
      
      emit(NearbyIssuesLoaded(issues: mockIssues));
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onRefreshNearbyIssues(
    RefreshNearbyIssues event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NearbyIssuesLoaded) {
        emit(NearbyIssuesRefreshing(issues: currentState.issues));
        
        // Here we would re-fetch data from repositories
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Mock data for issues
        final mockIssues = _getMockIssues();
        
        emit(NearbyIssuesLoaded(issues: mockIssues));
      }
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      // Update the location and re-fetch issues based on new location
      final currentState = state;
      if (currentState is NearbyIssuesLoaded) {
        emit(NearbyIssuesLoading());
        
        // Here we would re-fetch data from repositories with new location
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Mock data for issues with updated location
        final mockIssues = _getMockIssues();
        
        emit(NearbyIssuesLoaded(
          issues: mockIssues,
          location: event.location,
        ));
      }
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
    }
  }

  Future<void> _onFilterNearbyIssues(
    FilterNearbyIssues event,
    Emitter<NearbyIssuesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NearbyIssuesLoaded) {
        // Apply filtering locally or fetch filtered data from repository
        emit(NearbyIssuesLoading());
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock filtered issues based on filter
        final mockIssues = _getMockIssues().where((issue) {
          // Apply filters
          if (event.categoryFilter != null && 
              issue.category != event.categoryFilter) {
            return false;
          }
          
          if (event.statusFilter != null && 
              issue.status != event.statusFilter) {
            return false;
          }
          
          return true;
        }).toList();
        
        emit(NearbyIssuesLoaded(
          issues: mockIssues,
          location: currentState.location,
          activeFilters: {
            if (event.categoryFilter != null)
              'category': event.categoryFilter,
            if (event.statusFilter != null)
              'status': event.statusFilter,
          },
        ));
      }
    } catch (error) {
      emit(NearbyIssuesError(message: error.toString()));
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
      Issue(
        id: '3',
        title: 'Garbage not collected for a week',
        description: 'The garbage bins are overflowing and causing health issues.',
        category: IssueCategory.sanitation,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
        status: IssueStatus.resolved,
        priority: IssuePriority.medium,
        location: GeoLocation(
          latitude: 19.0760,
          longitude: 72.8779,
          address: 'Market Area, Station Road',
          locality: 'Malad',
          adminArea: 'Mumbai',
          pinCode: '400064',
        ),
        reporterId: 'user789',
        reporterName: 'Amit Kumar',
        mediaUrls: ['https://example.com/image2.jpg', 'https://example.com/image3.jpg'],
        upvotes: 8,
        adminLevel: AdminLevel.panchayat,
        assignedDepartment: 'Sanitation Department',
        isPublic: true,
        updates: [
          IssueUpdate(
            id: 'update2',
            timestamp: now.subtract(const Duration(days: 5)),
            comment: 'Issue has been assigned to sanitation department',
            previousStatus: IssueStatus.new_issue,
            newStatus: IssueStatus.in_progress,
            updatedBy: 'admin2',
            updaterName: 'Admin User',
            updaterRole: 'Panchayat Officer',
            mediaUrls: [],
          ),
          IssueUpdate(
            id: 'update3',
            timestamp: now.subtract(const Duration(days: 1)),
            comment: 'The area has been cleaned and bins have been emptied.',
            previousStatus: IssueStatus.in_progress,
            newStatus: IssueStatus.resolved,
            updatedBy: 'officer1',
            updaterName: 'Sanitation Officer',
            updaterRole: 'Field Officer',
            mediaUrls: ['https://example.com/image4.jpg'],
          ),
        ],
      ),
    ];
  }
}
