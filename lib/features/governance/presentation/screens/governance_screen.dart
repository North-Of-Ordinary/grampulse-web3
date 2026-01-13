/// Governance Screen - DAO Governance & Voting UI
/// Part of PHASE 5: Web3 Governance & Transparency

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/governance/presentation/bloc/governance_bloc.dart';
import 'package:grampulse/core/theme/color_schemes.dart';

class GovernanceScreen extends StatelessWidget {
  const GovernanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkSurfaces.level0 : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? DarkSurfaces.level1 : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Governance & Voting',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<GovernanceBloc, GovernanceState>(
        builder: (context, state) {
          if (state is GovernanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GovernanceError) {
            return _buildErrorView(context, state.message, colorScheme);
          }

          if (state is VoteCasting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Casting your vote on blockchain...',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            );
          }

          if (state is VoteCasted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Vote casted successfully! TX: ${state.transactionHash.substring(0, 10)}...',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            });
          }

          if (state is GovernanceLoaded) {
            return _buildContent(context, state, colorScheme, isDark);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to load governance', style: TextStyle(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<GovernanceBloc>().add(LoadGovernanceParams()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GovernanceLoaded state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GovernanceBloc>().add(LoadGovernanceParams());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voting Power Card
            _buildVotingPowerCard(state.userVotingPower, colorScheme, isDark),
            const SizedBox(height: 20),

            // Governance Info
            if (state.parameters != null)
              _buildGovernanceInfo(state.parameters!, colorScheme, isDark),
            const SizedBox(height: 20),

            // Active Proposals
            _buildSectionTitle('Active Proposals', colorScheme),
            const SizedBox(height: 12),
            ...state.proposals
                .where((p) => p.isActive)
                .map((p) => _buildProposalCard(context, p, colorScheme, isDark)),

            if (state.proposals.where((p) => p.isActive).isEmpty)
              _buildEmptyState('No active proposals', Icons.how_to_vote_outlined, colorScheme, isDark),

            const SizedBox(height: 24),

            // Past Proposals
            _buildSectionTitle('Past Proposals', colorScheme),
            const SizedBox(height: 12),
            ...state.proposals
                .where((p) => !p.isActive)
                .map((p) => _buildProposalCard(context, p, colorScheme, isDark)),

            if (state.proposals.where((p) => !p.isActive).isEmpty)
              _buildEmptyState('No past proposals', Icons.history, colorScheme, isDark),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingPowerCard(int votingPower, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.how_to_vote,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Voting Power',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$votingPower GP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Delegate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernanceInfo(GovernanceParameters params, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkSurfaces.level2 : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Voting Period', '${params.votingPeriod} days', colorScheme),
          _buildInfoItem('Quorum', '${params.quorumPercentage}%', colorScheme),
          _buildInfoItem('Threshold', '${params.proposalThreshold} GP', colorScheme),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildProposalCard(
    BuildContext context,
    Proposal proposal,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final statusColor = _getStatusColor(proposal.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkSurfaces.level2 : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  proposal.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  proposal.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            proposal.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Voting Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'For: ${proposal.forPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Against: ${proposal.againstPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: proposal.forPercentage / 100,
                        backgroundColor: Colors.red.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vote Buttons (only for active proposals)
          if (proposal.isActive && !proposal.hasVoted)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _castVote(context, proposal.id, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade600),
                    ),
                    child: const Text('Against'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _castVote(context, proposal.id, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                    ),
                    child: const Text('For'),
                  ),
                ),
              ],
            ),

          if (proposal.hasVoted)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'You have voted',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ),

          // Time remaining
          if (proposal.isActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeRemaining(proposal.endTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? DarkSurfaces.level2 : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkSurfaces.borderMedium : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'passed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'executed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeRemaining(DateTime endTime) {
    final remaining = endTime.difference(DateTime.now());
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m remaining';
    } else {
      return 'Ending soon';
    }
  }

  void _castVote(BuildContext context, String proposalId, bool support) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(support ? 'Vote For' : 'Vote Against'),
        content: const Text('Are you sure you want to cast this vote? This action will be recorded on the blockchain and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GovernanceBloc>().add(CastVote(
                proposalId: proposalId,
                support: support,
              ));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About Governance'),
        content: const SingleChildScrollView(
          child: Text(
            'GramPulse DAO Governance allows community members to participate in decision-making.\n\n'
            '• Voting Power: Earned through reputation and contributions\n'
            '• Proposals: Anyone with enough GP tokens can create proposals\n'
            '• Voting: All votes are recorded on the blockchain\n'
            '• Quorum: Minimum participation required for proposals to pass\n\n'
            'Your votes shape the future of your community!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
