/// Governance BLoC - State Management for DAO Governance

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/web3/governance_service.dart';

// Events
abstract class GovernanceEvent extends Equatable {
  const GovernanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadGovernanceParams extends GovernanceEvent {}

class LoadProposal extends GovernanceEvent {
  final String proposalId;
  const LoadProposal(this.proposalId);

  @override
  List<Object?> get props => [proposalId];
}

class CreateProposal extends GovernanceEvent {
  final String title;
  final String description;
  final String category;
  final double? budgetAmount;
  final String? proposerId;
  final String? panchayatId;

  const CreateProposal({
    required this.title,
    required this.description,
    required this.category,
    this.budgetAmount,
    this.proposerId,
    this.panchayatId,
  });

  @override
  List<Object?> get props => [title, description, category, budgetAmount, proposerId, panchayatId];
}

class CastVote extends GovernanceEvent {
  final String proposalId;
  final VoteType support;
  final String? reason;
  final String? voterId;

  const CastVote({
    required this.proposalId,
    required this.support,
    this.reason,
    this.voterId,
  });

  @override
  List<Object?> get props => [proposalId, support, reason, voterId];
}

class CheckVoteStatus extends GovernanceEvent {
  final String proposalId;
  final String address;

  const CheckVoteStatus({
    required this.proposalId,
    required this.address,
  });

  @override
  List<Object?> get props => [proposalId, address];
}

// States
abstract class GovernanceState extends Equatable {
  const GovernanceState();

  @override
  List<Object?> get props => [];
}

class GovernanceInitial extends GovernanceState {}

class GovernanceLoading extends GovernanceState {}

class GovernanceParamsLoaded extends GovernanceState {
  final GovernanceParams params;

  const GovernanceParamsLoaded(this.params);

  @override
  List<Object?> get props => [params];
}

class GovernanceNotConfigured extends GovernanceState {}

class ProposalLoaded extends GovernanceState {
  final Proposal proposal;

  const ProposalLoaded(this.proposal);

  @override
  List<Object?> get props => [proposal];
}

class ProposalCreated extends GovernanceState {
  final Proposal proposal;

  const ProposalCreated(this.proposal);

  @override
  List<Object?> get props => [proposal];
}

class VoteCast extends GovernanceState {
  final VoteResult result;

  const VoteCast(this.result);

  @override
  List<Object?> get props => [result];
}

class VoteStatusChecked extends GovernanceState {
  final String proposalId;
  final bool hasVoted;

  const VoteStatusChecked({
    required this.proposalId,
    required this.hasVoted,
  });

  @override
  List<Object?> get props => [proposalId, hasVoted];
}

class GovernanceError extends GovernanceState {
  final String message;

  const GovernanceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GovernanceBloc extends Bloc<GovernanceEvent, GovernanceState> {
  final GovernanceService _governanceService;

  GovernanceBloc({GovernanceService? governanceService})
      : _governanceService = governanceService ?? GovernanceService(),
        super(GovernanceInitial()) {
    on<LoadGovernanceParams>(_onLoadGovernanceParams);
    on<LoadProposal>(_onLoadProposal);
    on<CreateProposal>(_onCreateProposal);
    on<CastVote>(_onCastVote);
    on<CheckVoteStatus>(_onCheckVoteStatus);
  }

  Future<void> _onLoadGovernanceParams(
    LoadGovernanceParams event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(GovernanceLoading());

    try {
      final params = await _governanceService.getGovernanceParams();
      
      if (!params.configured) {
        emit(GovernanceNotConfigured());
      } else {
        emit(GovernanceParamsLoaded(params));
      }
    } catch (e) {
      // If we can't connect, assume not configured
      emit(GovernanceNotConfigured());
    }
  }

  Future<void> _onLoadProposal(
    LoadProposal event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(GovernanceLoading());

    try {
      final proposal = await _governanceService.getProposal(event.proposalId);
      emit(ProposalLoaded(proposal));
    } catch (e) {
      emit(GovernanceError(e.toString()));
    }
  }

  Future<void> _onCreateProposal(
    CreateProposal event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(GovernanceLoading());

    try {
      final proposal = await _governanceService.createProposal(
        title: event.title,
        description: event.description,
        category: event.category,
        budgetAmount: event.budgetAmount,
        proposerId: event.proposerId,
        panchayatId: event.panchayatId,
      );
      emit(ProposalCreated(proposal));
    } catch (e) {
      emit(GovernanceError(e.toString()));
    }
  }

  Future<void> _onCastVote(
    CastVote event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(GovernanceLoading());

    try {
      final result = await _governanceService.castVote(
        proposalId: event.proposalId,
        support: event.support,
        reason: event.reason,
        voterId: event.voterId,
      );
      emit(VoteCast(result));
    } catch (e) {
      emit(GovernanceError(e.toString()));
    }
  }

  Future<void> _onCheckVoteStatus(
    CheckVoteStatus event,
    Emitter<GovernanceState> emit,
  ) async {
    try {
      final hasVoted = await _governanceService.hasVoted(
        event.proposalId,
        event.address,
      );
      emit(VoteStatusChecked(
        proposalId: event.proposalId,
        hasVoted: hasVoted,
      ));
    } catch (e) {
      emit(GovernanceError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _governanceService.dispose();
    return super.close();
  }
}
