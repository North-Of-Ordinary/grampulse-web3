/// Dashboard Widgets - UI Components for Transparency Dashboard

import 'package:flutter/material.dart';
import 'package:grampulse/core/services/web3/dashboard_service.dart';

/// Stat Card Widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend Chart Widget
class TrendChart extends StatelessWidget {
  final TrendData trend;

  const TrendChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.points.isEmpty) {
      return Card(
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No data available'),
          ),
        ),
      );
    }

    final maxCount = trend.points.map((p) => p.count).reduce((a, b) => a > b ? a : b);
    final chartHeight = 120.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trend.points.map((point) {
                  final barHeight = maxCount > 0 
                      ? (point.count / maxCount) * chartHeight 
                      : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Tooltip(
                        message: '${_formatDate(point.date)}: ${point.count}',
                        child: Container(
                          height: barHeight.clamp(4.0, chartHeight),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(trend.points.first.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatDate(trend.points.last.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Average', '${trend.average.toStringAsFixed(1)}/day'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text('$label: $value'),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

/// Category Bar Widget
class CategoryBar extends StatelessWidget {
  final CategoryStats category;

  const CategoryBar({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${category.count} (${category.percentage.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: category.percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_getCategoryColor(category.name)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[name.hashCode % colors.length];
  }
}

/// Panchayat Rank Card Widget
class PanchayatRankCard extends StatelessWidget {
  final PanchayatRanking ranking;

  const PanchayatRankCard({super.key, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(ranking.rank).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '#${ranking.rank}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(ranking.rank),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ranking.panchayatId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ranking.totalResolutions} resolutions • ${ranking.averageResolutionTimeHours.toStringAsFixed(1)}h avg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Grade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(ranking.gradeColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ranking.grade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(ranking.gradeColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }
}

/// Recent Attestation Card Widget
class RecentAttestationCard extends StatelessWidget {
  final RecentAttestation attestation;

  const RecentAttestationCard({super.key, required this.attestation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.verified, color: Colors.green, size: 24),
        ),
        title: Text(
          attestation.shortUid,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        subtitle: Text(
          attestation.category != null 
              ? '${attestation.category} • ${_formatTime(attestation.timestamp)}'
              : _formatTime(attestation.timestamp),
        ),
        trailing: attestation.resolutionTimeHours != null
            ? Chip(
                label: Text('${attestation.resolutionTimeHours!.toStringAsFixed(1)}h'),
                backgroundColor: Colors.blue.withOpacity(0.1),
              )
            : null,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Leaderboard Entry Widget
class LeaderboardEntryWidget extends StatelessWidget {
  final int rank;
  final String address;
  final int score;
  final String? displayName;

  const LeaderboardEntryWidget({
    super.key,
    required this.rank,
    required this.address,
    required this.score,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildRankBadge(),
        title: Text(
          displayName ?? _shortenAddress(address),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              score.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    IconData icon;
    Color color;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber[700]!;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey[400]!;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.brown[300]!;
        break;
      default:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _shortenAddress(String addr) {
    if (addr.length > 12) {
      return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
    }
    return addr;
  }
}
