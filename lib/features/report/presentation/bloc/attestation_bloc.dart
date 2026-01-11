/// Attestation BLoC
/// 
/// Manages blockchain attestation operations for grievance resolutions

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/core/services/web3/attestation_service.dart';
import 'package:grampulse/core/config/web3_config.dart';
import 'attestation_event.dart';
import 'attestation_state.dart';

class AttestationBloc extends Bloc<AttestationEvent, AttestationState> {
  final AttestationService _attestationService;
  final bool _isEnabled;

  AttestationBloc({
    AttestationService? attestationService,
  })  : _attestationService = attestationService ?? AttestationService.instance,
        _isEnabled = Web3Config.instance.web3Enabled,
        super(const AttestationInitial()) {
    on<CreateResolutionAttestation>(_onCreateResolutionAttestation);
    on<VerifyAttestation>(_onVerifyAttestation);
    on<CheckAttestationService>(_onCheckAttestationService);
    on<ResetAttestationState>(_onResetAttestationState);
  }

  /// Check if Web3 attestations are enabled
  bool get isEnabled => _isEnabled;

  Future<void> _onCreateResolutionAttestation(
    CreateResolutionAttestation event,
    Emitter<AttestationState> emit,
  ) async {
    if (!_isEnabled) {
      emit(const AttestationError(
        message: 'Blockchain attestations are disabled',
        details: 'Enable Web3 in configuration to create attestations',
      ));
      return;
    }

    emit(const AttestationLoading(message: 'Creating blockchain attestation...'));

    try {
      final result = await _attestationService.createResolutionAttestation(
        grievanceId: event.grievanceId,
        villageId: event.villageId,
        resolverRole: event.resolverRole,
        resolverId: event.resolverId,
        description: event.description,
        proofFiles: event.proofFiles,
      );

      if (result.success) {
        emit(AttestationCreated(
          attestationUid: result.attestationUid!,
          transactionHash: result.transactionHash,
          explorerUrl: result.explorerUrl,
          ipfsCid: result.ipfsCid,
          ipfsUrl: result.ipfsUrl,
          timestamp: result.timestamp,
        ));
      } else {
        emit(AttestationError(
          message: 'Failed to create attestation',
          details: result.error,
        ));
      }
    } catch (e) {
      emit(AttestationError(
        message: 'Attestation error',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onVerifyAttestation(
    VerifyAttestation event,
    Emitter<AttestationState> emit,
  ) async {
    emit(const AttestationLoading(message: 'Verifying attestation...'));

    try {
      final result = await _attestationService.verifyAttestation(event.attestationUid);

      emit(AttestationVerified(
        isValid: result.valid,
        grievanceId: result.grievanceId,
        villageId: result.villageId,
        resolverRole: result.resolverRole,
        ipfsHash: result.ipfsHash,
        resolutionTimestamp: result.resolutionTimestamp,
        attester: result.attester,
        error: result.error,
      ));
    } catch (e) {
      emit(AttestationError(
        message: 'Verification error',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onCheckAttestationService(
    CheckAttestationService event,
    Emitter<AttestationState> emit,
  ) async {
    emit(const AttestationLoading(message: 'Checking service status...'));

    try {
      final health = await _attestationService.getHealthStatus();
      
      emit(AttestationServiceStatus(
        isAvailable: health['status'] == 'healthy',
        network: health['network'] as String?,
        attesterAddress: health['attesterAddress'] as String?,
        schemaUid: health['schemaUid'] as String?,
        error: health['error'] as String?,
      ));
    } catch (e) {
      emit(AttestationServiceStatus(
        isAvailable: false,
        error: e.toString(),
      ));
    }
  }

  void _onResetAttestationState(
    ResetAttestationState event,
    Emitter<AttestationState> emit,
  ) {
    emit(const AttestationInitial());
  }
}
