/// Reputation Widgets - UI Components for Reputation System

import 'package:flutter/material.dart';
import 'package:grampulse/core/services/web3/reputation_service.dart';

/// Leaderboard Entry Card
class LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final VoidCallback? onTap;

  const LeaderboardEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildRankBadge(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName ?? entry.shortAddress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTierChip(),
                  ],
                ),
              ),
              _buildScoreDisplay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    Color color;
    Widget content;

    switch (entry.rank) {
      case 1:
        color = Colors.amber[700]!;
        content = const Icon(Icons.emoji_events, color: Colors.white, size: 24);
        break;
      case 2:
        color = Colors.grey[400]!;
        content = const Icon(Icons.emoji_events, color: Colors.white, size: 24);
        break;
      case 3:
        color = Colors.brown[300]!;
        content = const Icon(Icons.emoji_events, color: Colors.white, size: 24);
        break;
      default:
        color = Colors.blue;
        content = Text(
          '#${entry.rank}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(child: content),
    );
  }

  Widget _buildTierChip() {
    final score = ReputationScore(
      address: entry.address,
      score: entry.score,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Color(score.tierColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        score.tier,
        style: TextStyle(
          color: Color(score.tierColor),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              entry.score.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'points',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Badge Card Widget
class BadgeCard extends StatelessWidget {
  final BadgeType badgeType;
  final bool earned;
  final DateTime? earnedAt;

  const BadgeCard({
    super.key,
    required this.badgeType,
    this.earned = false,
    this.earnedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: earned ? Colors.green.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badgeType.emoji,
              style: TextStyle(
                fontSize: 36,
                color: earned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badgeType.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: earned ? null : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (earned && earnedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Earned ${_formatDate(earnedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Officer Details Sheet
class OfficerDetailsSheet extends StatelessWidget {
  final String address;

  const OfficerDetailsSheet({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile section
              _buildProfileSection(context),
              const SizedBox(height: 24),
              
              // Stats section
              _buildStatsSection(context),
              const SizedBox(height: 24),
              
              // Badges section
              Text(
                'Earned Badges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildBadgesSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.person, size: 32, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _shortenAddress(address),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Officer',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(context, 'Score', '500', Icons.star, Colors.amber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(context, 'Badges', '3', Icons.military_tech, Colors.purple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(context, 'Resolved', '50', Icons.check_circle, Colors.green),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    // Placeholder badges
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        BadgeType.quickResolver,
        BadgeType.firstResponder,
        BadgeType.milestone100,
      ].map((type) => SizedBox(
        width: 100,
        child: BadgeCard(badgeType: type, earned: true),
      )).toList(),
    );
  }

  String _shortenAddress(String addr) {
    if (addr.length > 12) {
      return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
    }
    return addr;
  }
}

/// Score Progress Widget
class ScoreProgressWidget extends StatelessWidget {
  final int currentScore;
  final int nextMilestone;

  const ScoreProgressWidget({
    super.key,
    required this.currentScore,
    required this.nextMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentScore / nextMilestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$currentScore pts'),
            Text('$nextMilestone pts'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Colors.amber),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% to next milestone',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Reputation Tier Widget
class ReputationTierWidget extends StatelessWidget {
  final ReputationScore score;

  const ReputationTierWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(score.tierColor).withOpacity(0.1),
            Color(score.tierColor).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(score.tierColor).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(score.tierColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTierIcon(score.tier),
              color: Color(score.tierColor),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.tier,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(score.tierColor),
                  ),
                ),
                Text(
                  '${score.score} reputation points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTierIcon(String tier) {
    switch (tier) {
      case 'Legendary':
        return Icons.emoji_events;
      case 'Master':
        return Icons.workspace_premium;
      case 'Expert':
        return Icons.verified;
      case 'Skilled':
        return Icons.star;
      case 'Active':
        return Icons.trending_up;
      default:
        return Icons.person;
    }
  }
}
