/// Governance Screen - DAO Proposals and Voting
///
/// Displays governance proposals and allows voting for
/// panchayat community decisions.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/governance/presentation/bloc/governance_bloc.dart';
import 'package:grampulse/features/governance/presentation/widgets/governance_widgets.dart';
import 'package:grampulse/core/services/web3/governance_service.dart';

/// Governance Screen
class GovernanceScreen extends StatelessWidget {
  const GovernanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GovernanceBloc()..add(LoadGovernanceParams()),
      child: const _GovernanceView(),
    );
  }
}

class _GovernanceView extends StatelessWidget {
  const _GovernanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panchayat Governance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGovernanceInfo(context),
          ),
        ],
      ),
      body: BlocConsumer<GovernanceBloc, GovernanceState>(
        listener: (context, state) {
          if (state is ProposalCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Proposal created: ${state.proposal.title}'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is VoteCast) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vote cast on proposal ${state.result.proposalId}'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is GovernanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GovernanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GovernanceParamsLoaded) {
            return _buildGovernanceContent(context, state.params);
          }

          if (state is GovernanceNotConfigured) {
            return _buildNotConfigured(context);
          }

          return _buildGovernanceContent(context, null);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProposalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Proposal'),
      ),
    );
  }

  Widget _buildGovernanceContent(BuildContext context, GovernanceParams? params) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Governance Overview Card
          _buildOverviewCard(context, params),
          const SizedBox(height: 24),
          
          // Active Proposals Section
          Text(
            'Active Proposals',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProposalsList(context),
          
          const SizedBox(height: 24),
          
          // How It Works Section
          _buildHowItWorks(context),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, GovernanceParams? params) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.how_to_vote, color: Colors.purple, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        params?.name ?? 'GramPulse DAO',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Decentralized community governance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (params != null && params.configured) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildParamItem(
                      context,
                      'Voting Period',
                      '${params.votingPeriod ?? 'N/A'} blocks',
                      Icons.schedule,
                    ),
                  ),
                  Expanded(
                    child: _buildParamItem(
                      context,
                      'Quorum',
                      params.quorum ?? 'N/A',
                      Icons.people,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParamItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  Widget _buildProposalsList(BuildContext context) {
    // Placeholder for proposals list
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.ballot_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No active proposals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create a proposal for your panchayat!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'How Governance Works',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStep(context, '1', 'Create Proposal', 'Submit a proposal for community budget or initiatives'),
            _buildStep(context, '2', 'Community Voting', 'Community members vote For, Against, or Abstain'),
            _buildStep(context, '3', 'Execution', 'Passed proposals are executed on-chain'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildNotConfigured(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_suggest, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Governance Not Configured',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The DAO governance contract has not been deployed yet. '
              'Contact your administrator to enable governance features.',
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

  void _showGovernanceInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const GovernanceInfoSheet(),
    );
  }

  void _showCreateProposalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateProposalDialog(),
    );
  }
}
