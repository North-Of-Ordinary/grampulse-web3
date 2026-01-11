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
    return BlocProvider(
      create: (_) => ReputationBloc()..add(LoadLeaderboard()),
      child: const _LeaderboardView(),
    );
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
            if (state is ReputationLoading) {
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
      color: Colors.amber.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
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
          ],
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

class _BadgesTab extends StatelessWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIntro(context),
          const SizedBox(height: 24),
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
        ],
      ),
    );
  }

  Widget _buildBadgeIntro(BuildContext context) {
    return Card(
      color: Colors.purple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.military_tech, size: 36, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soulbound Badges',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Non-transferable NFT badges earned through achievements',
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
