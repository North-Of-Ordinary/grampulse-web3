/// Governance Widgets - UI Components for DAO Governance

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/governance/presentation/bloc/governance_bloc.dart';
import 'package:grampulse/core/services/web3/governance_service.dart';

/// Proposal Card Widget
class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback? onVote;
  final VoidCallback? onDetails;

  const ProposalCard({
    super.key,
    required this.proposal,
    this.onVote,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStateChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proposal.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              if (proposal.votes != null) _buildVoteProgress(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category: ${proposal.category}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (proposal.isVotingActive)
                    ElevatedButton.icon(
                      onPressed: onVote,
                      icon: const Icon(Icons.how_to_vote, size: 18),
                      label: const Text('Vote'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateChip() {
    Color color;
    String label;

    switch (proposal.state) {
      case ProposalState.pending:
        color = Colors.grey;
        label = 'Pending';
        break;
      case ProposalState.active:
        color = Colors.green;
        label = 'Active';
        break;
      case ProposalState.succeeded:
        color = Colors.blue;
        label = 'Passed';
        break;
      case ProposalState.executed:
        color = Colors.purple;
        label = 'Executed';
        break;
      case ProposalState.defeated:
        color = Colors.red;
        label = 'Defeated';
        break;
      case ProposalState.canceled:
        color = Colors.orange;
        label = 'Canceled';
        break;
      default:
        color = Colors.grey;
        label = proposal.state.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildVoteProgress() {
    final votes = proposal.votes!;
    final total = votes.total;
    
    if (total == BigInt.zero) {
      return const LinearProgressIndicator(value: 0);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('For: ${votes.forPercentage.toStringAsFixed(1)}%'),
            Text('Against: ${votes.againstPercentage.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: votes.forPercentage / 100,
            backgroundColor: Colors.red.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.green),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Vote Dialog Widget
class VoteDialog extends StatefulWidget {
  final String proposalId;
  final String proposalTitle;

  const VoteDialog({
    super.key,
    required this.proposalId,
    required this.proposalTitle,
  });

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  VoteType? _selectedVote;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cast Your Vote'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.proposalTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Vote',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildVoteOption(VoteType.forVote, 'For', Colors.green),
              const SizedBox(width: 12),
              _buildVoteOption(VoteType.against, 'Against', Colors.red),
              const SizedBox(width: 12),
              _buildVoteOption(VoteType.abstain, 'Abstain', Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'Why are you voting this way?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedVote != null ? _submitVote : null,
          child: const Text('Submit Vote'),
        ),
      ],
    );
  }

  Widget _buildVoteOption(VoteType type, String label, Color color) {
    final isSelected = _selectedVote == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedVote = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                _getVoteIcon(type),
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVoteIcon(VoteType type) {
    switch (type) {
      case VoteType.forVote:
        return Icons.thumb_up;
      case VoteType.against:
        return Icons.thumb_down;
      case VoteType.abstain:
        return Icons.remove_circle_outline;
    }
  }

  void _submitVote() {
    if (_selectedVote == null) return;

    context.read<GovernanceBloc>().add(CastVote(
      proposalId: widget.proposalId,
      support: _selectedVote!,
      reason: _reasonController.text.isEmpty ? null : _reasonController.text,
    ));

    Navigator.pop(context);
  }
}

/// Create Proposal Dialog
class CreateProposalDialog extends StatefulWidget {
  const CreateProposalDialog({super.key});

  @override
  State<CreateProposalDialog> createState() => _CreateProposalDialogState();
}

class _CreateProposalDialogState extends State<CreateProposalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedCategory = 'Infrastructure';

  final List<String> _categories = [
    'Infrastructure',
    'Education',
    'Healthcare',
    'Environment',
    'Agriculture',
    'Social Welfare',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Proposal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter proposal title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your proposal',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (optional)',
                  hintText: 'Estimated budget in INR',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitProposal,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submitProposal() {
    if (!_formKey.currentState!.validate()) return;

    context.read<GovernanceBloc>().add(CreateProposal(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      budgetAmount: _budgetController.text.isNotEmpty 
          ? double.tryParse(_budgetController.text) 
          : null,
    ));

    Navigator.pop(context);
  }
}

/// Governance Info Sheet
class GovernanceInfoSheet extends StatelessWidget {
  const GovernanceInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Panchayat Governance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            Icons.how_to_vote,
            'Decentralized Voting',
            'All votes are recorded on-chain for transparency and immutability.',
          ),
          _buildInfoItem(
            context,
            Icons.people,
            'Community Driven',
            'Any community member can create proposals and participate in voting.',
          ),
          _buildInfoItem(
            context,
            Icons.verified,
            'Verifiable Results',
            'Voting results can be independently verified on the blockchain.',
          ),
          _buildInfoItem(
            context,
            Icons.lock,
            'Secure & Trustless',
            'Smart contracts ensure fair and tamper-proof governance.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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
}
