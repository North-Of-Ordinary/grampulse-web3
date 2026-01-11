/// Attestation BLoC Events
/// 
/// Events for managing blockchain attestation operations

import 'dart:io';

abstract class AttestationEvent {
  const AttestationEvent();
}

/// Create a resolution attestation when a grievance is resolved
class CreateResolutionAttestation extends AttestationEvent {
  final String grievanceId;
  final String villageId;
  final String resolverRole;
  final String resolverId;
  final String? description;
  final List<File>? proofFiles;

  const CreateResolutionAttestation({
    required this.grievanceId,
    required this.villageId,
    required this.resolverRole,
    required this.resolverId,
    this.description,
    this.proofFiles,
  });
}

/// Verify an existing attestation
class VerifyAttestation extends AttestationEvent {
  final String attestationUid;

  const VerifyAttestation(this.attestationUid);
}

/// Check attestation service health
class CheckAttestationService extends AttestationEvent {
  const CheckAttestationService();
}

/// Reset attestation state
class ResetAttestationState extends AttestationEvent {
  const ResetAttestationState();
}
