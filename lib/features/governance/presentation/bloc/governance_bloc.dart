/// Governance BLoC - State Management for DAO Governance & Voting
/// Part of PHASE 5: Web3 Governance & Transparency

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class GovernanceEvent extends Equatable {
  const GovernanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadGovernanceParams extends GovernanceEvent {}

class LoadProposals extends GovernanceEvent {
  final String? status; // 'active', 'passed', 'rejected', 'all'
  const LoadProposals({this.status});

  @override
  List<Object?> get props => [status];
}

class LoadProposalDetails extends GovernanceEvent {
  final String proposalId;
  const LoadProposalDetails(this.proposalId);

  @override
  List<Object?> get props => [proposalId];
}

class CastVote extends GovernanceEvent {
  final String proposalId;
  final bool support;
  final String? reason;

  const CastVote({
    required this.proposalId,
    required this.support,
    this.reason,
  });

  @override
  List<Object?> get props => [proposalId, support, reason];
}

class CreateProposal extends GovernanceEvent {
  final String title;
  final String description;
  final List<String> targets;
  final List<String> calldatas;

  const CreateProposal({
    required this.title,
    required this.description,
    required this.targets,
    required this.calldatas,
  });

  @override
  List<Object?> get props => [title, description, targets, calldatas];
}

// Proposal Model
class Proposal extends Equatable {
  final String id;
  final String title;
  final String description;
  final String proposer;
  final DateTime startTime;
  final DateTime endTime;
  final int forVotes;
  final int againstVotes;
  final int abstainVotes;
  final String status; // 'active', 'passed', 'rejected', 'pending', 'executed'
  final bool hasVoted;

  const Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.proposer,
    required this.startTime,
    required this.endTime,
    required this.forVotes,
    required this.againstVotes,
    required this.abstainVotes,
    required this.status,
    this.hasVoted = false,
  });

  double get totalVotes => (forVotes + againstVotes + abstainVotes).toDouble();
  double get forPercentage => totalVotes > 0 ? (forVotes / totalVotes) * 100 : 0;
  double get againstPercentage => totalVotes > 0 ? (againstVotes / totalVotes) * 100 : 0;
  bool get isActive => status == 'active' && DateTime.now().isBefore(endTime);

  @override
  List<Object?> get props => [
    id, title, description, proposer, startTime, endTime,
    forVotes, againstVotes, abstainVotes, status, hasVoted,
  ];
}

// Governance Parameters
class GovernanceParameters extends Equatable {
  final int votingDelay;
  final int votingPeriod;
  final int proposalThreshold;
  final int quorumPercentage;
  final String tokenAddress;
  final int totalSupply;

  const GovernanceParameters({
    required this.votingDelay,
    required this.votingPeriod,
    required this.proposalThreshold,
    required this.quorumPercentage,
    required this.tokenAddress,
    required this.totalSupply,
  });

  @override
  List<Object?> get props => [
    votingDelay, votingPeriod, proposalThreshold,
    quorumPercentage, tokenAddress, totalSupply,
  ];
}

// States
abstract class GovernanceState extends Equatable {
  const GovernanceState();

  @override
  List<Object?> get props => [];
}

class GovernanceInitial extends GovernanceState {}

class GovernanceLoading extends GovernanceState {}

class GovernanceLoaded extends GovernanceState {
  final List<Proposal> proposals;
  final GovernanceParameters? parameters;
  final int userVotingPower;

  const GovernanceLoaded({
    required this.proposals,
    this.parameters,
    this.userVotingPower = 0,
  });

  @override
  List<Object?> get props => [proposals, parameters, userVotingPower];
}

class GovernanceError extends GovernanceState {
  final String message;

  const GovernanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class VoteCasting extends GovernanceState {}

class VoteCasted extends GovernanceState {
  final String proposalId;
  final bool support;
  final String transactionHash;

  const VoteCasted({
    required this.proposalId,
    required this.support,
    required this.transactionHash,
  });

  @override
  List<Object?> get props => [proposalId, support, transactionHash];
}

// BLoC
class GovernanceBloc extends Bloc<GovernanceEvent, GovernanceState> {
  GovernanceBloc() : super(GovernanceInitial()) {
    on<LoadGovernanceParams>(_onLoadGovernanceParams);
    on<LoadProposals>(_onLoadProposals);
    on<CastVote>(_onCastVote);
    on<CreateProposal>(_onCreateProposal);
  }

  Future<void> _onLoadGovernanceParams(
    LoadGovernanceParams event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(GovernanceLoading());

    try {
      // Governance proposals will be implemented in future phases
      // For now, show empty proposals
      const proposals = <Proposal>[];

      const parameters = GovernanceParameters(
        votingDelay: 1,
        votingPeriod: 7,
        proposalThreshold: 100,
        quorumPercentage: 4,
        tokenAddress: '0x0000...0000',
        totalSupply: 100000,
      );

      emit(GovernanceLoaded(
        proposals: proposals,
        parameters: parameters,
        userVotingPower: 0,
      ));
    } catch (e) {
      emit(GovernanceError(e.toString()));
    }
  }

  Future<void> _onLoadProposals(
    LoadProposals event,
    Emitter<GovernanceState> emit,
  ) async {
    // Reload proposals with optional filter
    add(LoadGovernanceParams());
  }

  Future<void> _onCastVote(
    CastVote event,
    Emitter<GovernanceState> emit,
  ) async {
    final currentState = state;
    emit(VoteCasting());

    try {
      // Simulate vote transaction
      await Future.delayed(const Duration(seconds: 2));

      emit(VoteCasted(
        proposalId: event.proposalId,
        support: event.support,
        transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      ));

      // Reload proposals after voting
      if (currentState is GovernanceLoaded) {
        await Future.delayed(const Duration(milliseconds: 500));
        add(LoadGovernanceParams());
      }
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
      // Simulate proposal creation
      await Future.delayed(const Duration(seconds: 2));
      add(LoadGovernanceParams());
    } catch (e) {
      emit(GovernanceError(e.toString()));
    }
  }
}
