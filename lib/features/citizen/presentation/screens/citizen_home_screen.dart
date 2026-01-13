import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:grampulse/core/theme/app_theme.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/citizen/domain/models/issue_model.dart';
import 'package:grampulse/features/citizen/presentation/bloc/citizen_home/citizen_home_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/citizen_home/citizen_home_event.dart';
import 'package:grampulse/features/citizen/presentation/bloc/citizen_home/citizen_home_state.dart';
import 'package:grampulse/features/citizen/presentation/bloc/nearby_issues/nearby_issues_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/my_issues/my_issues_bloc.dart';
import 'package:grampulse/features/citizen/presentation/widgets/issue_card.dart';
import 'package:grampulse/features/citizen/presentation/widgets/map_preview.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_state.dart';
import 'package:grampulse/core/services/quadratic_voting_service.dart';
import 'dart:math' show sqrt;
import 'package:grampulse/l10n/l10n.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CitizenHomeBloc>(
          create: (context) => CitizenHomeBloc()..add(const LoadDashboard()),
        ),
        BlocProvider<NearbyIssuesBloc>(
          create: (context) => NearbyIssuesBloc()..add(LoadNearbyIssues()),
        ),
        BlocProvider<MyIssuesBloc>(
          create: (context) => MyIssuesBloc()..add(LoadMyIssues()),
        ),
      ],
      child: BlocBuilder<CitizenHomeBloc, CitizenHomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CitizenHomeBloc>().add(const RefreshDashboard());
              await Future.delayed(Duration(seconds: 1));
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, state),
                if (state is CitizenHomeLoaded) ...[
                  _buildLocationBar(context, state),
                  _buildVotingSection(context, state),
                  _buildNearbyIssuesSection(context),
                  _buildMyIssuesSection(context),
                ] else if (state is CitizenHomeLoading) ...[
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ] else if (state is CitizenHomeError) ...[
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(state.message),
                          SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CitizenHomeBloc>().add(const LoadDashboard());
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  SliverAppBar _buildAppBar(BuildContext context, CitizenHomeState state) {
    return SliverAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GramPulse'),
          Text(
            state is CitizenHomeLoaded 
                ? state.userName 
                : 'Loading...',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      actions: [
        // Quadratic Voting Button
        IconButton(
          icon: const Icon(Icons.how_to_vote),
          tooltip: 'Vote on Issues',
          onPressed: () => context.push('/voting'),
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Navigate to notifications when route is available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => context.go('/citizen/profile'),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, size: 16, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
      floating: true,
    );
  }
  
  SliverToBoxAdapter _buildLocationBar(BuildContext context, CitizenHomeLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  "Current Location", // Replace with proper location handling
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  SliverToBoxAdapter _buildNearbyIssuesSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issues Near Me',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/citizen/explore'),
                  child: Text('View Map'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            BlocBuilder<NearbyIssuesBloc, NearbyIssuesState>(
              builder: (context, state) {
                if (state is NearbyIssuesLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is NearbyIssuesLoaded) {
                  return Column(
                    children: [
                      // Map preview
                      MapPreview(
                        center: LatLng(19.0760, 72.8777), // Default to a fixed location for now
                        issues: state.issues.map((issue) => {
                          'id': issue.id,
                          'title': issue.title,
                          'category': issue.category.toString().split('.').last,
                          'status': issue.status.toString().split('.').last,
                          'location': issue.location.getFormattedAddress(),
                          'coordinates': LatLng(issue.location.latitude, issue.location.longitude),
                          'distance': '${(issue.location.latitude - 19.0760).abs() + (issue.location.longitude - 72.8777).abs()} km',
                          'createdAt': issue.createdAt,
                        }).toList(),
                        radius: 2.0, // Default radius in km
                        onTap: () => context.go('/citizen/explore'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Horizontal issue cards
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.issues.length,
                          itemBuilder: (context, index) {
                            final issue = state.issues[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == state.issues.length - 1 ? 0 : AppSpacing.sm,
                              ),
                              child: SizedBox(
                                width: 250,
                                child: IssueCard.nearby(
                                  id: issue.id,
                                  title: issue.title,
                                  category: issue.category.toString().split('.').last,
                                  status: issue.status.toString().split('.').last,
                                  location: issue.location.getFormattedAddress(),
                                  distance: '${((issue.location.latitude - 19.0760).abs() + (issue.location.longitude - 72.8777).abs()).toStringAsFixed(1)} km',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Issue details: ${issue.title}')),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state is NearbyIssuesError) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
  
  SliverToBoxAdapter _buildMyIssuesSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Reported Issues',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/citizen/my-reports'),
                  child: Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            BlocBuilder<MyIssuesBloc, MyIssuesState>(
              builder: (context, state) {
                if (state is MyIssuesLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is MyIssuesLoaded) {
                  if (state.reportedIssues.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No issues reported yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: () => context.push('/citizen/report-issue'),
                            child: Text('Report an Issue'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      // Status filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(context, 'All', 'all', state.activeFilters?['status'] ?? 'all'),
                            _buildFilterChip(context, 'New', 'new', state.activeFilters?['status'] ?? 'all'),
                            _buildFilterChip(context, 'In Progress', 'in_progress', state.activeFilters?['status'] ?? 'all'),
                            _buildFilterChip(context, 'Resolved', 'resolved', state.activeFilters?['status'] ?? 'all'),
                            _buildFilterChip(context, 'Overdue', 'overdue', state.activeFilters?['status'] ?? 'all'),
                            _buildFilterChip(context, 'Verified', 'verified', state.activeFilters?['status'] ?? 'all'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // List of my issues
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.reportedIssues.length > 3 ? 3 : state.reportedIssues.length,
                        itemBuilder: (context, index) {
                          final issue = state.reportedIssues[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == state.reportedIssues.length - 1 ? 0 : AppSpacing.sm,
                            ),
                            child: IssueCard.my(
                              id: issue.id,
                              title: issue.title,
                              category: issue.category.toString().split('.').last,
                              status: issue.status.toString().split('.').last,
                              location: issue.location.getFormattedAddress(),
                              date: issue.createdAt,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Issue details: ${issue.title}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } else if (state is MyIssuesError) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(BuildContext context, String label, String value, String currentFilter) {
    final isSelected = value == currentFilter;
    
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            context.read<MyIssuesBloc>().add(FilterMyIssues(statusFilter: value == 'all' ? null : IssueStatus.values.firstWhere(
              (e) => e.toString().split('.').last == value,
              orElse: () => IssueStatus.new_issue,
            )));
          }
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  SliverToBoxAdapter _buildVotingSection(BuildContext context, CitizenHomeLoaded state) {
    final authState = context.watch<AuthBloc>().state;
    String? userId;
    if (authState is Authenticated) {
      userId = authState.user.id;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.how_to_vote,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quadratic Voting',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push('/voting'),
                  child: Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // User credits display
            if (userId != null)
              FutureBuilder<UserCredits>(
                future: QuadraticVotingService().getUserCredits(userId),
                builder: (context, snapshot) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Voting Credits',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              snapshot.hasData ? '${snapshot.data!.balance} credits' : 'Loading...',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor.withOpacity(0.6),
                        ),
                      ],
                    ),
                  );
                },
              ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Top voted issues
            Text(
              'Top Voted Issues',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            FutureBuilder<List<IncidentWithVotes>>(
              future: QuadraticVotingService().getIncidentsWithVotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.ballot_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No issues to vote on yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final topIssues = snapshot.data!.take(3).toList();
                
                return Column(
                  children: topIssues.map((incident) {
                    final title = incident.title;
                    final totalVotes = incident.voteStats.totalVotes;
                    final voterCount = incident.voteStats.voterCount;
                    final weightedVotes = incident.voteStats.totalVotes;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => context.push('/voting'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              // Vote indicator
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$totalVotes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'votes',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              
                              // Issue info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$voterCount voters',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Icon(
                                          Icons.scale,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Weight: $weightedVotes',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Vote button
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Call to action
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    Theme.of(context).primaryColor.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Use quadratic voting to prioritize issues. Cost = Votes²',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
