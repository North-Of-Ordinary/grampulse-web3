/// GramPulse Transparency Dashboard Screen
///
/// Public transparency dashboard showing:
/// - Attestation statistics
/// - Resolution metrics
/// - Panchayat performance rankings
/// - Daily trends

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:grampulse/core/services/web3/dashboard_service.dart';
import 'package:grampulse/features/dashboard/presentation/widgets/dashboard_widgets.dart';

/// Transparency Dashboard Screen
class TransparencyDashboardScreen extends StatelessWidget {
  const TransparencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparency Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(LoadDashboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading transparency data...'),
                ],
              ),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load dashboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboard());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(LoadDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Cards
                    _buildOverviewSection(context, state.stats),
                    const SizedBox(height: 24),
                    
                    // Network Info
                    _buildNetworkInfo(context, state.stats.overview.network),
                    const SizedBox(height: 24),
                    
                    // Weekly Trend Chart
                    _buildTrendSection(context, state.stats.weeklyTrend),
                    const SizedBox(height: 24),
                    
                    // Category Distribution
                    _buildCategorySection(context, state.stats.topCategories),
                    const SizedBox(height: 24),
                    
                    // Panchayat Rankings
                    _buildPanchayatSection(context, state.stats.topPanchayats),
                    const SizedBox(height: 24),
                    
                    // Footer
                    _buildFooter(context, state.stats.generatedAt),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, AggregateStats stats) {
    final overview = stats.overview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: 'Total Attestations',
              value: overview.totalAttestations.toString(),
              icon: Icons.verified,
              color: Colors.green,
            ),
            StatCard(
              title: 'Resolutions',
              value: overview.totalResolutions.toString(),
              icon: Icons.check_circle,
              color: Colors.blue,
            ),
            StatCard(
              title: 'Avg Resolution Time',
              value: '${overview.averageResolutionTimeHours.toStringAsFixed(1)}h',
              icon: Icons.timer,
              color: Colors.orange,
            ),
            StatCard(
              title: 'Active Panchayats',
              value: overview.panchayatsActive.toString(),
              icon: Icons.location_city,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkInfo(BuildContext context, NetworkInfo network) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.link, color: Colors.red),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blockchain Network',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${network.name} (Chain ID: ${network.chainId})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 8),
                  SizedBox(width: 6),
                  Text('Live', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSection(BuildContext context, TrendData trend) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Total: ${trend.total}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TrendChart(trend: trend),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, List<CategoryStats> categories) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issues by Category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CategoryBar(category: category),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanchayatSection(BuildContext context, List<PanchayatRanking> rankings) {
    if (rankings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panchayat Performance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...rankings.map((ranking) => PanchayatRankCard(ranking: ranking)),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, DateTime generatedAt) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All data is publicly verifiable on-chain',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${_formatDateTime(generatedAt)}',
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
