/// Leaderboard Screen - Officer/Volunteer Reputation Rankings
///
/// Displays reputation scores, badges, and leaderboard rankings
/// for officers and volunteers.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/reputation/presentation/bloc/reputation_bloc.dart';
import 'package:grampulse/features/reputation/presentation/widgets/reputation_widgets.dart';
import 'package:grampulse/core/services/web3/reputation_service.dart';

/// Leaderboard Screen
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LeaderboardView();
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Rankings', icon: Icon(Icons.leaderboard)),
              Tab(text: 'Badges', icon: Icon(Icons.military_tech)),
            ],
          ),
        ),
        body: BlocBuilder<ReputationBloc, ReputationState>(
          builder: (context, state) {
            if (state is ReputationLoading || state is ReputationInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReputationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ReputationBloc>().add(LoadLeaderboard());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const TabBarView(
              children: [
                _RankingsTab(),
                _BadgesTab(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RankingsTab extends StatelessWidget {
  const _RankingsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReputationBloc, ReputationState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReputationBloc>().add(LoadLeaderboard());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.entries.length + 1, // +1 for header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context);
                }
                final entry = state.entries[index - 1];
                return LeaderboardEntryCard(
                  entry: entry,
                  onTap: () => _showOfficerDetails(context, entry.address),
                );
              },
            ),
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.leaderboard,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Top Performers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Officers and volunteers ranked by reputation points',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton(context, 'All Time', true),
                _buildFilterButton(context, 'This Month', false),
                _buildFilterButton(context, 'This Week', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String label, bool isSelected) {
    return TextButton(
      onPressed: () {
        // Reload leaderboard with filter
        context.read<ReputationBloc>().add(LoadLeaderboard());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Showing $label rankings'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No rankings yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resolve issues to earn reputation points!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showOfficerDetails(BuildContext context, String address) {
    context.read<ReputationBloc>().add(LoadReputationScore(address));
    context.read<ReputationBloc>().add(LoadBadges(address));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OfficerDetailsSheet(address: address),
    );
  }
}

class _BadgesTab extends StatefulWidget {
  const _BadgesTab();

  @override
  State<_BadgesTab> createState() => _BadgesTabState();
}

class _BadgesTabState extends State<_BadgesTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIntro(context),
          const SizedBox(height: 20),
          _buildFilterChips(context),
          const SizedBox(height: 20),
          Text(
            'Available Badges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBadgeGrid(context),
          const SizedBox(height: 24),
          _buildPointsInfo(context),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'Earned', 'Locked', 'Milestone'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Refresh badges
              context.read<ReputationBloc>().add(LoadLeaderboard());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing badge data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Badges'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showMyProgressDialog(context),
            icon: const Icon(Icons.analytics),
            label: const Text('View My Progress'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showMyProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('My Progress'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressItem(context, 'Total Points', '150', Icons.star, Colors.amber),
            const Divider(),
            _buildProgressItem(context, 'Badges Earned', '2/10', Icons.military_tech, Colors.purple),
            const Divider(),
            _buildProgressItem(context, 'Issues Resolved', '45', Icons.check_circle, Colors.green),
            const Divider(),
            _buildProgressItem(context, 'Current Rank', '#12', Icons.leaderboard, Colors.blue),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to rankings tab
              DefaultTabController.of(context).animateTo(0);
            },
            child: const Text('View Rankings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIntro(BuildContext context) {
    return Card(
      color: Colors.deepPurple.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified, size: 36, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievement Badges',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Blockchain-verified credentials earned through performance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: BadgeType.values.map((type) {
        return BadgeCard(badgeType: type);
      }).toList(),
    );
  }

  Widget _buildPointsInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'How to Earn Points',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPointItem(context, 'Issue Resolved', '+10 pts'),
            _buildPointItem(context, 'Quick Resolution (<24h)', '+5 pts'),
            _buildPointItem(context, 'First Responder', '+2 pts'),
            _buildPointItem(context, 'Positive Feedback', '+3 pts'),
            _buildPointItem(context, 'Community Event', '+15 pts'),
            _buildPointItem(context, 'Training Completed', '+20 pts'),
          ],
        ),
      ),
    );
  }

  Widget _buildPointItem(BuildContext context, String action, String points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              points,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
