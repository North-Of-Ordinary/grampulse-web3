import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/services/quadratic_voting_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VOTING WIDGET
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// A widget that allows users to cast quadratic votes on an incident.
/// Shows:
/// - Current credit balance
/// - Vote slider (1-10 votes)
/// - Real-time cost preview (cost = votes²)
/// - Cast vote button
/// ═══════════════════════════════════════════════════════════════════════════

class VotingWidget extends StatefulWidget {
  final String incidentId;
  final String incidentTitle;
  final String userId;
  final int currentCredits;
  final VoidCallback? onVoteSuccess;
  final bool useEncryption; // Inco Network encrypted voting

  const VotingWidget({
    super.key,
    required this.incidentId,
    required this.incidentTitle,
    required this.userId,
    required this.currentCredits,
    this.onVoteSuccess,
    this.useEncryption = false,
  });

  @override
  State<VotingWidget> createState() => _VotingWidgetState();
}

class _VotingWidgetState extends State<VotingWidget> with SingleTickerProviderStateMixin {
  final QuadraticVotingService _votingService = QuadraticVotingService();
  
  int _voteCount = 1;
  bool _isVoting = false;
  late int _currentCredits;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentCredits = widget.currentCredits;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _cost => _votingService.calculateCost(_voteCount);
  int get _maxVotes => _votingService.calculateMaxVotes(_currentCredits);
  bool get _canAfford => _currentCredits >= _cost;

  Future<void> _castVote() async {
    if (_isVoting || !_canAfford) return;

    setState(() => _isVoting = true);

    final result = await _votingService.castVote(
      userId: widget.userId,
      incidentId: widget.incidentId,
      votes: _voteCount,
      useEncryption: widget.useEncryption,
    );

    setState(() => _isVoting = false);

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _currentCredits = result.remainingCredits!;
        _voteCount = 1;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✅ Cast ${result.votes} votes for ${result.cost} credits!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      widget.onVoteSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result.error}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with credits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cast Your Vote',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_currentCredits',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Encryption badge (if enabled)
          if (widget.useEncryption)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.purple.shade300),
                  const SizedBox(width: 6),
                  Text(
                    'Inco Encrypted Vote',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Vote count display with animation
          Center(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _canAfford ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _canAfford
                                ? [theme.primaryColor, theme.primaryColor.withOpacity(0.7)]
                                : [Colors.grey, Colors.grey.shade600],
                          ),
                          boxShadow: _canAfford
                              ? [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_voteCount',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _voteCount == 1 ? 'vote' : 'votes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Cost display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _canAfford 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _canAfford ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _canAfford ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: _canAfford ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cost: $_cost credits',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _canAfford ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Vote slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Slide to adjust votes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Max: $_maxVotes votes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: theme.primaryColor,
                  inactiveTrackColor: theme.primaryColor.withOpacity(0.2),
                  thumbColor: theme.primaryColor,
                  overlayColor: theme.primaryColor.withOpacity(0.2),
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                ),
                child: Slider(
                  value: _voteCount.toDouble(),
                  min: 1,
                  max: math.max(_maxVotes.toDouble(), 1.0),
                  divisions: math.max(_maxVotes - 1, 1),
                  label: '$_voteCount',
                  onChanged: (value) {
                    setState(() => _voteCount = value.round());
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Quadratic cost explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quadratic voting: Cost = Votes². More votes = exponentially more credits.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cast vote button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canAfford && !_isVoting ? _castVote : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _canAfford ? 4 : 0,
              ),
              child: _isVoting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.useEncryption ? Icons.lock : Icons.how_to_vote,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _canAfford
                              ? 'Cast $_voteCount ${_voteCount == 1 ? "Vote" : "Votes"} for $_cost Credits'
                              : 'Insufficient Credits',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of the voting widget for list items
class CompactVotingWidget extends StatelessWidget {
  final String incidentId;
  final String userId;
  final int currentCredits;
  final VoidCallback? onVote;

  const CompactVotingWidget({
    super.key,
    required this.incidentId,
    required this.userId,
    required this.currentCredits,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuickVoteButton(
          votes: 1,
          cost: 1,
          enabled: currentCredits >= 1,
          incidentId: incidentId,
          userId: userId,
          onVote: onVote,
        ),
        const SizedBox(width: 4),
        _QuickVoteButton(
          votes: 3,
          cost: 9,
          enabled: currentCredits >= 9,
          incidentId: incidentId,
          userId: userId,
          onVote: onVote,
        ),
        const SizedBox(width: 4),
        _QuickVoteButton(
          votes: 5,
          cost: 25,
          enabled: currentCredits >= 25,
          incidentId: incidentId,
          userId: userId,
          onVote: onVote,
        ),
      ],
    );
  }
}

class _QuickVoteButton extends StatefulWidget {
  final int votes;
  final int cost;
  final bool enabled;
  final String incidentId;
  final String userId;
  final VoidCallback? onVote;

  const _QuickVoteButton({
    required this.votes,
    required this.cost,
    required this.enabled,
    required this.incidentId,
    required this.userId,
    this.onVote,
  });

  @override
  State<_QuickVoteButton> createState() => _QuickVoteButtonState();
}

class _QuickVoteButtonState extends State<_QuickVoteButton> {
  final QuadraticVotingService _votingService = QuadraticVotingService();
  bool _isVoting = false;

  Future<void> _castQuickVote() async {
    if (_isVoting || !widget.enabled) return;

    setState(() => _isVoting = true);

    final result = await _votingService.castVote(
      userId: widget.userId,
      incidentId: widget.incidentId,
      votes: widget.votes,
    );

    setState(() => _isVoting = false);

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ +${widget.votes} votes!'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onVote?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled && !_isVoting ? _castQuickVote : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.enabled
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.enabled
                ? Theme.of(context).primaryColor.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: _isVoting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${widget.votes}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: widget.enabled
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                  Text(
                    '${widget.cost}c',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.enabled
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
