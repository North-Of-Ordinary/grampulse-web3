import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/quadratic_voting_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../widgets/voting_widget.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VOTING DASHBOARD SCREEN
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Real-time voting dashboard for demonstrating quadratic voting.
/// Shows:
/// - Two-column comparison of issues
/// - Live vote bars with real-time updates
/// - Urgency scoring (credits spent / votes = intensity)
/// - Demo controls for reset
/// ═══════════════════════════════════════════════════════════════════════════

class VotingDashboardScreen extends StatefulWidget {
  final String userId;

  const VotingDashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<VotingDashboardScreen> createState() => _VotingDashboardScreenState();
}

class _VotingDashboardScreenState extends State<VotingDashboardScreen> {
  final QuadraticVotingService _votingService = QuadraticVotingService();
  final SupabaseService _supabase = SupabaseService();

  List<IncidentWithVotes> _incidents = [];
  UserCredits? _userCredits;
  bool _isLoading = true;
  String? _error;
  
  StreamSubscription? _votesSubscription;
  StreamSubscription? _creditsSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupRealTimeSubscriptions();
  }

  @override
  void dispose() {
    _votesSubscription?.cancel();
    _creditsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeSubscriptions() {
    // Subscribe to vote updates
    _votingService.subscribeToVotes();
    _votesSubscription = _votingService.votesStream.listen((_) {
      _loadIncidents();
    });

    // Subscribe to credit updates
    _votingService.subscribeToCredits(widget.userId);
    _creditsSubscription = _votingService.creditsStream.listen((balance) {
      setState(() {
        _userCredits = UserCredits(
          userId: widget.userId,
          balance: balance,
          totalEarned: _userCredits?.totalEarned ?? 100,
          totalSpent: _userCredits?.totalSpent ?? 0,
          lastWeeklyRefresh: _userCredits?.lastWeeklyRefresh ?? DateTime.now(),
        );
      });
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credits = await _votingService.getUserCredits(widget.userId);
      final incidents = await _votingService.getIncidentsWithVotes();

      setState(() {
        _userCredits = credits;
        _incidents = incidents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadIncidents() async {
    try {
      final incidents = await _votingService.getIncidentsWithVotes();
      setState(() => _incidents = incidents);
    } catch (e) {
      debugPrint('Error loading incidents: $e');
    }
  }

  Future<void> _resetDemo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Demo?'),
        content: const Text(
          'This will clear all votes and reset everyone\'s credits to 100. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _votingService.clearAllVotes();
      await _votingService.resetDemoCredits();
      await _loadData();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Demo reset complete!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadratic Voting'),
        centerTitle: true,
        actions: [
          // Credits display
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_userCredits?.balance ?? 0}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          // Demo reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetDemo,
            tooltip: 'Reset Demo',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildDashboard(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header explanation
            _buildExplanationCard(),
            const SizedBox(height: 20),

            // Vote comparison section
            if (_incidents.isNotEmpty) ...[
              _buildVoteComparisonSection(),
              const SizedBox(height: 24),
            ],

            // All issues list
            _buildAllIssuesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calculate,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Quadratic Voting: Cost = Votes²',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Express how strongly you care! 1 vote = 1 credit, 2 votes = 4 credits, 5 votes = 25 credits, 10 votes = 100 credits.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCostExample('1 vote', '1 credit', Colors.green),
              ),
              Expanded(
                child: _buildCostExample('3 votes', '9 credits', Colors.orange),
              ),
              Expanded(
                child: _buildCostExample('10 votes', '100 credits', Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostExample(String votes, String cost, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            votes,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteComparisonSection() {
    // Show top 2 issues for comparison
    final topIssues = _incidents.take(2).toList();
    if (topIssues.length < 2) return const SizedBox.shrink();

    final maxVotes = topIssues
        .map((i) => i.voteStats.totalVotes)
        .reduce((a, b) => a > b ? a : b);
    final maxCredits = topIssues
        .map((i) => i.voteStats.totalCreditsSpent)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.compare_arrows, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Live Vote Comparison',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildComparisonCard(
                topIssues[0],
                maxVotes,
                maxCredits,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonCard(
                topIssues.length > 1 ? topIssues[1] : topIssues[0],
                maxVotes,
                maxCredits,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    IncidentWithVotes incident,
    int maxVotes,
    int maxCredits,
    Color color,
  ) {
    final votePercent = maxVotes > 0
        ? incident.voteStats.totalVotes / maxVotes
        : 0.0;
    final creditsPercent = maxCredits > 0
        ? incident.voteStats.totalCreditsSpent / maxCredits
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            incident.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Total votes bar
          _buildStatBar(
            label: 'Votes',
            value: incident.voteStats.totalVotes,
            percent: votePercent,
            color: color,
          ),
          const SizedBox(height: 8),
          
          // Credits spent bar
          _buildStatBar(
            label: 'Credits',
            value: incident.voteStats.totalCreditsSpent,
            percent: creditsPercent,
            color: Colors.amber,
          ),
          const SizedBox(height: 8),
          
          // Intensity indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Intensity:',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '${incident.voteStats.averageIntensity.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Voters count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${incident.voteStats.voterCount} voters',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required int value,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: percent.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllIssuesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'All Issues',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Text(
              '${_incidents.length} issues',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_incidents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'No issues to vote on yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _incidents.length,
            itemBuilder: (context, index) {
              final incident = _incidents[index];
              return _buildIssueCard(incident, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildIssueCard(IncidentWithVotes incident, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getRankColor(rank).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getRankColor(rank),
              ),
            ),
          ),
        ),
        title: Text(
          incident.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.how_to_vote, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              '${incident.voteStats.totalVotes} votes',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Icon(Icons.stars, size: 14, color: Colors.amber.shade600),
            const SizedBox(width: 4),
            Text(
              '${incident.voteStats.totalCreditsSpent} credits',
              style: TextStyle(fontSize: 12, color: Colors.amber.shade600),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                VotingWidget(
                  incidentId: incident.id,
                  incidentTitle: incident.title,
                  userId: widget.userId,
                  currentCredits: _userCredits?.balance ?? 0,
                  onVoteSuccess: _loadData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}
