/// Attestation BLoC States
/// 
/// States for managing blockchain attestation UI

import 'package:equatable/equatable.dart';

abstract class AttestationState extends Equatable {
  const AttestationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AttestationInitial extends AttestationState {
  const AttestationInitial();
}

/// Loading state (creating or verifying attestation)
class AttestationLoading extends AttestationState {
  final String message;

  const AttestationLoading({this.message = 'Processing...'});

  @override
  List<Object?> get props => [message];
}

/// Attestation created successfully
class AttestationCreated extends AttestationState {
  final String attestationUid;
  final String? transactionHash;
  final String? explorerUrl;
  final String? ipfsCid;
  final String? ipfsUrl;
  final int? timestamp;

  const AttestationCreated({
    required this.attestationUid,
    this.transactionHash,
    this.explorerUrl,
    this.ipfsCid,
    this.ipfsUrl,
    this.timestamp,
  });

  @override
  List<Object?> get props => [
        attestationUid,
        transactionHash,
        explorerUrl,
        ipfsCid,
        ipfsUrl,
        timestamp,
      ];
}

/// Attestation verified
class AttestationVerified extends AttestationState {
  final bool isValid;
  final String? grievanceId;
  final String? villageId;
  final String? resolverRole;
  final String? ipfsHash;
  final int? resolutionTimestamp;
  final String? attester;
  final String? error;

  const AttestationVerified({
    required this.isValid,
    this.grievanceId,
    this.villageId,
    this.resolverRole,
    this.ipfsHash,
    this.resolutionTimestamp,
    this.attester,
    this.error,
  });

  @override
  List<Object?> get props => [
        isValid,
        grievanceId,
        villageId,
        resolverRole,
        ipfsHash,
        resolutionTimestamp,
        attester,
        error,
      ];
}

/// Service health status
class AttestationServiceStatus extends AttestationState {
  final bool isAvailable;
  final String? network;
  final String? attesterAddress;
  final String? schemaUid;
  final String? error;

  const AttestationServiceStatus({
    required this.isAvailable,
    this.network,
    this.attesterAddress,
    this.schemaUid,
    this.error,
  });

  @override
  List<Object?> get props => [
        isAvailable,
        network,
        attesterAddress,
        schemaUid,
        error,
      ];
}

/// Error state
class AttestationError extends AttestationState {
  final String message;
  final String? details;

  const AttestationError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}
