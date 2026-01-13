/// Reputation BLoC - State Management for Reputation System (Uses Supabase)

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:grampulse/core/services/web3/reputation_service.dart';

// Events
abstract class ReputationEvent extends Equatable {
  const ReputationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends ReputationEvent {
  final int limit;
  const LoadLeaderboard({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class LoadReputationScore extends ReputationEvent {
  final String address;
  const LoadReputationScore(this.address);

  @override
  List<Object?> get props => [address];
}

class LoadBadges extends ReputationEvent {
  final String address;
  const LoadBadges(this.address);

  @override
  List<Object?> get props => [address];
}

class AddPoints extends ReputationEvent {
  final String address;
  final int points;
  final String reason;
  final String? issueId;

  const AddPoints({
    required this.address,
    required this.points,
    required this.reason,
    this.issueId,
  });

  @override
  List<Object?> get props => [address, points, reason, issueId];
}

class ProcessResolution extends ReputationEvent {
  final String resolverAddress;
  final String issueId;
  final double? resolutionTimeHours;
  final int? rating;
  final bool isFirstResponder;

  const ProcessResolution({
    required this.resolverAddress,
    required this.issueId,
    this.resolutionTimeHours,
    this.rating,
    this.isFirstResponder = false,
  });

  @override
  List<Object?> get props => [
    resolverAddress,
    issueId,
    resolutionTimeHours,
    rating,
    isFirstResponder,
  ];
}

class AwardBadgeEvent extends ReputationEvent {
  final String address;
  final BadgeType badgeType;
  final String? reason;

  const AwardBadgeEvent({
    required this.address,
    required this.badgeType,
    this.reason,
  });

  @override
  List<Object?> get props => [address, badgeType, reason];
}

// States
abstract class ReputationState extends Equatable {
  const ReputationState();

  @override
  List<Object?> get props => [];
}

class ReputationInitial extends ReputationState {}

class ReputationLoading extends ReputationState {}

class LeaderboardLoaded extends ReputationState {
  final List<LeaderboardEntry> entries;

  const LeaderboardLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class ReputationScoreLoaded extends ReputationState {
  final ReputationScore score;

  const ReputationScoreLoaded(this.score);

  @override
  List<Object?> get props => [score];
}

class BadgesLoaded extends ReputationState {
  final String address;
  final List<Badge> badges;

  const BadgesLoaded({
    required this.address,
    required this.badges,
  });

  @override
  List<Object?> get props => [address, badges];
}

class PointsAdded extends ReputationState {
  final ReputationUpdateResult result;

  const PointsAdded(this.result);

  @override
  List<Object?> get props => [result];
}

class ResolutionProcessed extends ReputationState {
  final ReputationUpdateResult result;

  const ResolutionProcessed(this.result);

  @override
  List<Object?> get props => [result];
}

class BadgeAwarded extends ReputationState {
  final Badge badge;

  const BadgeAwarded(this.badge);

  @override
  List<Object?> get props => [badge];
}

class ReputationError extends ReputationState {
  final String message;

  const ReputationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ReputationBloc extends Bloc<ReputationEvent, ReputationState> {
  final ReputationService _reputationService;
  final SupabaseService _supabase = SupabaseService();

  ReputationBloc({ReputationService? reputationService})
      : _reputationService = reputationService ?? ReputationService(),
        super(ReputationInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<LoadReputationScore>(_onLoadReputationScore);
    on<LoadBadges>(_onLoadBadges);
    on<AddPoints>(_onAddPoints);
    on<ProcessResolution>(_onProcessResolution);
    on<AwardBadgeEvent>(_onAwardBadge);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<ReputationState> emit,
  ) async {
    emit(ReputationLoading());
    debugPrint('[ReputationBloc] Loading leaderboard from Supabase...');

    try {
      // Get leaderboard from Supabase
      final leaderboardData = await _supabase.getLeaderboard(limit: event.limit);
      
      final entries = leaderboardData.asMap().entries.map((entry) {
        final data = entry.value;
        return LeaderboardEntry(
          address: data['id'] as String? ?? '',
          score: data['reputation_score'] as int? ?? 0,
          rank: entry.key + 1,
          displayName: data['name'] as String? ?? 'Anonymous',
        );
      }).toList();
      
      debugPrint('[ReputationBloc] ✅ Loaded ${entries.length} leaderboard entries');
      emit(LeaderboardLoaded(entries));
    } catch (e, stack) {
      debugPrint('[ReputationBloc] ❌ Error: $e');
      debugPrint('[ReputationBloc] Stack: $stack');
      emit(ReputationError('Failed to load leaderboard: $e'));
    }
  }

  Future<void> _onLoadReputationScore(
    LoadReputationScore event,
    Emitter<ReputationState> emit,
  ) async {
    emit(ReputationLoading());

    try {
      final score = await _reputationService.getReputationScore(event.address);
      emit(ReputationScoreLoaded(score));
    } catch (e) {
      emit(ReputationError(e.toString()));
    }
  }

  Future<void> _onLoadBadges(
    LoadBadges event,
    Emitter<ReputationState> emit,
  ) async {
    try {
      final badges = await _reputationService.getBadges(event.address);
      emit(BadgesLoaded(address: event.address, badges: badges));
    } catch (e) {
      emit(ReputationError(e.toString()));
    }
  }

  Future<void> _onAddPoints(
    AddPoints event,
    Emitter<ReputationState> emit,
  ) async {
    emit(ReputationLoading());

    try {
      final result = await _reputationService.addReputationPoints(
        address: event.address,
        points: event.points,
        reason: event.reason,
        issueId: event.issueId,
      );
      emit(PointsAdded(result));
    } catch (e) {
      emit(ReputationError(e.toString()));
    }
  }

  Future<void> _onProcessResolution(
    ProcessResolution event,
    Emitter<ReputationState> emit,
  ) async {
    emit(ReputationLoading());

    try {
      final result = await _reputationService.processResolutionReputation(
        resolverAddress: event.resolverAddress,
        issueId: event.issueId,
        resolutionTimeHours: event.resolutionTimeHours,
        rating: event.rating,
        isFirstResponder: event.isFirstResponder,
      );
      emit(ResolutionProcessed(result));
    } catch (e) {
      emit(ReputationError(e.toString()));
    }
  }

  Future<void> _onAwardBadge(
    AwardBadgeEvent event,
    Emitter<ReputationState> emit,
  ) async {
    emit(ReputationLoading());

    try {
      final badge = await _reputationService.awardBadge(
        address: event.address,
        badgeType: event.badgeType,
        reason: event.reason,
      );
      emit(BadgeAwarded(badge));
    } catch (e) {
      emit(ReputationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _reputationService.dispose();
    return super.close();
  }
}
