/// GramPulse Governance Service - DAO Client
///
/// Flutter client for interacting with the governance backend API.
/// Handles proposal creation, voting, and governance queries.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'web3_config.dart';

/// Proposal state enum
enum ProposalState {
  pending,
  active,
  canceled,
  defeated,
  succeeded,
  queued,
  expired,
  executed,
  unknown,
}

/// Vote type enum
enum VoteType {
  against,
  forVote,
  abstain,
}

/// Proposal model
class Proposal {
  final String id;
  final String title;
  final String description;
  final String category;
  final double? budgetAmount;
  final String? proposerId;
  final String? panchayatId;
  final ProposalState state;
  final String? snapshot;
  final String? deadline;
  final ProposalVotes? votes;
  final String? txHash;
  final DateTime? createdAt;

  Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.budgetAmount,
    this.proposerId,
    this.panchayatId,
    this.state = ProposalState.pending,
    this.snapshot,
    this.deadline,
    this.votes,
    this.txHash,
    this.createdAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['proposalId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      budgetAmount: json['budgetAmount']?.toDouble(),
      proposerId: json['proposerId'],
      panchayatId: json['panchayatId'],
      state: _parseState(json['state'] ?? json['status']),
      snapshot: json['snapshot'],
      deadline: json['deadline'],
      votes: json['votes'] != null ? ProposalVotes.fromJson(json['votes']) : null,
      txHash: json['txHash'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  static ProposalState _parseState(dynamic state) {
    if (state == null) return ProposalState.unknown;
    final stateStr = state.toString().toLowerCase();
    switch (stateStr) {
      case 'pending':
      case '0':
        return ProposalState.pending;
      case 'active':
      case '1':
        return ProposalState.active;
      case 'canceled':
      case '2':
        return ProposalState.canceled;
      case 'defeated':
      case '3':
        return ProposalState.defeated;
      case 'succeeded':
      case '4':
        return ProposalState.succeeded;
      case 'queued':
      case '5':
        return ProposalState.queued;
      case 'expired':
      case '6':
        return ProposalState.expired;
      case 'executed':
      case '7':
        return ProposalState.executed;
      default:
        return ProposalState.unknown;
    }
  }

  bool get isVotingActive => state == ProposalState.active;
  bool get isPassed => state == ProposalState.succeeded || state == ProposalState.executed;
  bool get isFailed => state == ProposalState.defeated || state == ProposalState.canceled;
}

/// Proposal votes model
class ProposalVotes {
  final BigInt against;
  final BigInt forVotes;
  final BigInt abstain;

  ProposalVotes({
    required this.against,
    required this.forVotes,
    required this.abstain,
  });

  factory ProposalVotes.fromJson(Map<String, dynamic> json) {
    return ProposalVotes(
      against: BigInt.tryParse(json['against']?.toString() ?? '0') ?? BigInt.zero,
      forVotes: BigInt.tryParse(json['for']?.toString() ?? '0') ?? BigInt.zero,
      abstain: BigInt.tryParse(json['abstain']?.toString() ?? '0') ?? BigInt.zero,
    );
  }

  BigInt get total => against + forVotes + abstain;
  
  double get forPercentage => total > BigInt.zero 
      ? (forVotes.toDouble() / total.toDouble()) * 100 
      : 0;
  
  double get againstPercentage => total > BigInt.zero 
      ? (against.toDouble() / total.toDouble()) * 100 
      : 0;
  
  double get abstainPercentage => total > BigInt.zero 
      ? (abstain.toDouble() / total.toDouble()) * 100 
      : 0;
}

/// Governance parameters model
class GovernanceParams {
  final bool configured;
  final String? name;
  final String? votingDelay;
  final String? votingPeriod;
  final String? proposalThreshold;
  final String? quorum;
  final int? currentBlock;

  GovernanceParams({
    required this.configured,
    this.name,
    this.votingDelay,
    this.votingPeriod,
    this.proposalThreshold,
    this.quorum,
    this.currentBlock,
  });

  factory GovernanceParams.fromJson(Map<String, dynamic> json) {
    return GovernanceParams(
      configured: json['configured'] ?? false,
      name: json['name'],
      votingDelay: json['votingDelay'],
      votingPeriod: json['votingPeriod'],
      proposalThreshold: json['proposalThreshold'],
      quorum: json['quorum'],
      currentBlock: json['currentBlock'],
    );
  }
}

/// Vote result model
class VoteResult {
  final bool success;
  final String proposalId;
  final String? txHash;
  final VoteType support;
  final String? reason;

  VoteResult({
    required this.success,
    required this.proposalId,
    this.txHash,
    required this.support,
    this.reason,
  });

  factory VoteResult.fromJson(Map<String, dynamic> json) {
    return VoteResult(
      success: json['success'] ?? false,
      proposalId: json['proposalId']?.toString() ?? '',
      txHash: json['txHash'],
      support: VoteType.values[json['support'] ?? 1],
      reason: json['reason'],
    );
  }
}

/// Governance Service for DAO operations
class GovernanceService {
  final Web3Config _config;
  final http.Client _client;
  
  GovernanceService({
    Web3Config? config,
    http.Client? client,
  }) : _config = config ?? Web3Config.fromEnvironment(),
       _client = client ?? http.Client();

  String get _baseUrl => _config.backendUrl;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _config.backendApiKey,
  };

  /// Create a new proposal
  Future<Proposal> createProposal({
    required String title,
    required String description,
    required String category,
    double? budgetAmount,
    String? proposerId,
    String? panchayatId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/governance/proposal'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
          if (budgetAmount != null) 'budgetAmount': budgetAmount,
          if (proposerId != null) 'proposerId': proposerId,
          if (panchayatId != null) 'panchayatId': panchayatId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Proposal.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw GovernanceException(error['error'] ?? 'Failed to create proposal');
      }
    } catch (e) {
      if (e is GovernanceException) rethrow;
      throw GovernanceException('Network error: $e');
    }
  }

  /// Cast a vote on a proposal
  Future<VoteResult> castVote({
    required String proposalId,
    required VoteType support,
    String? reason,
    String? voterId,
  }) async {
    try {
      String supportStr;
      switch (support) {
        case VoteType.against:
          supportStr = 'against';
          break;
        case VoteType.forVote:
          supportStr = 'for';
          break;
        case VoteType.abstain:
          supportStr = 'abstain';
          break;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/governance/vote'),
        headers: _headers,
        body: jsonEncode({
          'proposalId': proposalId,
          'support': supportStr,
          if (reason != null) 'reason': reason,
          if (voterId != null) 'voterId': voterId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VoteResult.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw GovernanceException(error['error'] ?? 'Failed to cast vote');
      }
    } catch (e) {
      if (e is GovernanceException) rethrow;
      throw GovernanceException('Network error: $e');
    }
  }

  /// Get proposal details
  Future<Proposal> getProposal(String proposalId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/governance/proposal/$proposalId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Proposal.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw GovernanceException(error['error'] ?? 'Failed to get proposal');
      }
    } catch (e) {
      if (e is GovernanceException) rethrow;
      throw GovernanceException('Network error: $e');
    }
  }

  /// Get governance parameters
  Future<GovernanceParams> getGovernanceParams() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/governance/params'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GovernanceParams.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw GovernanceException(error['error'] ?? 'Failed to get governance params');
      }
    } catch (e) {
      if (e is GovernanceException) rethrow;
      throw GovernanceException('Network error: $e');
    }
  }

  /// Check if an address has voted on a proposal
  Future<bool> hasVoted(String proposalId, String address) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/governance/voted/$proposalId/$address'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['hasVoted'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error checking vote status: $e');
      return false;
    }
  }

  /// Get voting power for an address
  Future<BigInt> getVotingPower(String address) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/governance/voting-power/$address'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BigInt.tryParse(data['data']['votingPower']?.toString() ?? '0') ?? BigInt.zero;
      } else {
        return BigInt.zero;
      }
    } catch (e) {
      debugPrint('Error getting voting power: $e');
      return BigInt.zero;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Governance exception
class GovernanceException implements Exception {
  final String message;
  GovernanceException(this.message);
  
  @override
  String toString() => 'GovernanceException: $message';
}
