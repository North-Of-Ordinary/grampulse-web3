/// Attestation BLoC - State Management for Blockchain Attestation Verification
/// Part of PHASE 5: Web3 Governance & Transparency (Uses Supabase)

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grampulse/core/services/supabase_service.dart';

// Events
abstract class AttestationEvent extends Equatable {
  const AttestationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyAttestation extends AttestationEvent {
  final String uid;
  const VerifyAttestation(this.uid);

  @override
  List<Object?> get props => [uid];
}

class LoadRecentAttestations extends AttestationEvent {
  final int limit;
  const LoadRecentAttestations({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class SearchAttestation extends AttestationEvent {
  final String query;
  const SearchAttestation(this.query);

  @override
  List<Object?> get props => [query];
}

// Attestation Model
class AttestationDetails extends Equatable {
  final String uid;
  final String issueId;
  final String issueType;
  final String status;
  final String reporter;
  final String resolver;
  final DateTime timestamp;
  final String transactionHash;
  final String blockNumber;
  final Map<String, dynamic>? metadata;
  final bool isVerified;

  const AttestationDetails({
    required this.uid,
    required this.issueId,
    required this.issueType,
    required this.status,
    required this.reporter,
    required this.resolver,
    required this.timestamp,
    required this.transactionHash,
    required this.blockNumber,
    this.metadata,
    this.isVerified = true,
  });

  @override
  List<Object?> get props => [
    uid, issueId, issueType, status, reporter, resolver,
    timestamp, transactionHash, blockNumber, metadata, isVerified,
  ];
}

// States
abstract class AttestationState extends Equatable {
  const AttestationState();

  @override
  List<Object?> get props => [];
}

class AttestationInitial extends AttestationState {}

class AttestationLoading extends AttestationState {}

class AttestationVerified extends AttestationState {
  final AttestationDetails attestation;

  const AttestationVerified(this.attestation);

  @override
  List<Object?> get props => [attestation];
}

class AttestationNotFound extends AttestationState {
  final String uid;

  const AttestationNotFound(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AttestationError extends AttestationState {
  final String message;

  const AttestationError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttestationListLoaded extends AttestationState {
  final List<AttestationDetails> attestations;

  const AttestationListLoaded(this.attestations);

  @override
  List<Object?> get props => [attestations];
}

// BLoC
class AttestationBloc extends Bloc<AttestationEvent, AttestationState> {
  final SupabaseService _supabase = SupabaseService();
  
  AttestationBloc() : super(AttestationInitial()) {
    on<VerifyAttestation>(_onVerifyAttestation);
    on<LoadRecentAttestations>(_onLoadRecentAttestations);
    on<SearchAttestation>(_onSearchAttestation);
  }

  Future<void> _onVerifyAttestation(
    VerifyAttestation event,
    Emitter<AttestationState> emit,
  ) async {
    emit(AttestationLoading());

    try {
      debugPrint('[AttestationBloc] Verifying attestation: ${event.uid}');
      
      // Look up incident by ID in Supabase
      final incidents = await _supabase.getAllIncidents();
      final incident = incidents.firstWhere(
        (inc) => inc['id'] == event.uid || inc['blockchain_tx_hash'] == event.uid,
        orElse: () => <String, dynamic>{},
      );

      if (incident.isNotEmpty) {
        final attestation = AttestationDetails(
          uid: incident['id'] as String? ?? event.uid,
          issueId: incident['id'] as String? ?? '',
          issueType: (incident['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
          status: incident['status'] as String? ?? 'submitted',
          reporter: incident['user_id'] as String? ?? '',
          resolver: incident['assigned_officer_id'] as String? ?? '',
          timestamp: DateTime.tryParse(incident['created_at'] as String? ?? '') ?? DateTime.now(),
          transactionHash: incident['blockchain_tx_hash'] as String? ?? '',
          blockNumber: incident['blockchain_block'] as String? ?? '',
          metadata: {
            'location': incident['location_address'] ?? '',
            'priority': incident['priority'] ?? 'medium',
          },
          isVerified: incident['blockchain_tx_hash'] != null,
        );

        debugPrint('[AttestationBloc] ✅ Found attestation for ${event.uid}');
        emit(AttestationVerified(attestation));
      } else {
        debugPrint('[AttestationBloc] ❌ Attestation not found: ${event.uid}');
        emit(AttestationNotFound(event.uid));
      }
    } catch (e) {
      debugPrint('[AttestationBloc] ❌ Error: $e');
      emit(AttestationError(e.toString()));
    }
  }

  Future<void> _onLoadRecentAttestations(
    LoadRecentAttestations event,
    Emitter<AttestationState> emit,
  ) async {
    emit(AttestationLoading());

    try {
      debugPrint('[AttestationBloc] Loading recent attestations from Supabase...');
      
      final incidents = await _supabase.getIncidents(limit: event.limit);
      
      final attestations = incidents.map((inc) => AttestationDetails(
        uid: inc['id'] as String? ?? '',
        issueId: inc['id'] as String? ?? '',
        issueType: (inc['categories'] as Map<String, dynamic>?)?['name'] as String? ?? 'Other',
        status: inc['status'] as String? ?? 'submitted',
        reporter: inc['user_id'] as String? ?? '',
        resolver: inc['assigned_officer_id'] as String? ?? '',
        timestamp: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
        transactionHash: inc['blockchain_tx_hash'] as String? ?? '',
        blockNumber: inc['blockchain_block'] as String? ?? '',
        isVerified: inc['blockchain_tx_hash'] != null,
      )).toList();

      debugPrint('[AttestationBloc] ✅ Loaded ${attestations.length} attestations');
      emit(AttestationListLoaded(attestations));
    } catch (e) {
      debugPrint('[AttestationBloc] ❌ Error: $e');
      emit(AttestationError(e.toString()));
    }
  }

  Future<void> _onSearchAttestation(
    SearchAttestation event,
    Emitter<AttestationState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(AttestationInitial());
      return;
    }

    add(VerifyAttestation(event.query));
  }
}
