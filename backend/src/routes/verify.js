/**
 * GramPulse Verification Routes
 * 
 * Endpoints for verifying attestations on the blockchain
 */

const express = require('express');
const easService = require('../services/easService');
const logger = require('../utils/logger');

const router = express.Router();

/**
 * GET /verify/:uid
 * 
 * Verifies an attestation by its UID
 * 
 * This endpoint is PUBLIC - no API key required
 * Anyone can verify an attestation's authenticity
 * 
 * Params:
 * - uid: The attestation UID (0x...)
 * 
 * Response:
 * - valid: boolean
 * - attestation: Decoded attestation data (if valid)
 * - error: Error message (if invalid)
 */
router.get('/:uid', async (req, res, next) => {
  const { uid } = req.params;

  // Validate UID format (should be a 66-character hex string)
  if (!uid || !/^0x[a-fA-F0-9]{64}$/.test(uid)) {
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Invalid attestation UID format. Expected 0x followed by 64 hex characters.',
    });
  }

  logger.info('Verification request', { uid });

  try {
    const result = await easService.verifyAttestation(uid);

    if (result.valid) {
      res.json({
        valid: true,
        attestation: result.attestation,
      });
    } else {
      res.status(404).json({
        valid: false,
        error: result.error,
        ...(result.revokedAt && { revokedAt: result.revokedAt }),
      });
    }

  } catch (error) {
    logger.error('Verification failed', {
      uid,
      error: error.message,
    });
    next(error);
  }
});

/**
 * GET /verify/grievance/:grievanceId
 * 
 * Checks if a grievance has been attested on-chain
 * 
 * This endpoint searches for attestations related to a specific grievance
 * Note: This is a simplified implementation. In production, you might
 * want to use The Graph or an indexer for efficient querying.
 * 
 * Params:
 * - grievanceId: Firebase document ID
 * 
 * Response:
 * - hasAttestation: boolean
 * - attestationUid: UID if found
 */
router.get('/grievance/:grievanceId', async (req, res, next) => {
  const { grievanceId } = req.params;

  if (!grievanceId) {
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Grievance ID is required',
    });
  }

  // TODO: Implement attestation lookup by grievance ID
  // This would require either:
  // 1. Storing attestation UIDs in Firebase alongside grievances
  // 2. Using The Graph to index attestations
  // 3. Maintaining a local database of attestation mappings
  
  res.status(501).json({
    error: 'Not Implemented',
    message: 'Grievance attestation lookup requires additional indexing infrastructure. Use the direct UID verification for now.',
    suggestion: 'Store the attestationUid in Firebase when creating the attestation',
  });
});

/**
 * GET /verify/health
 * 
 * Health check for the verification service
 */
router.get('/health', async (req, res) => {
  try {
    const schemaUid = easService.getResolutionSchemaUid();
    const attesterAddress = easService.getAttesterAddress();

    res.json({
      status: 'healthy',
      service: 'verification',
      schemaUid,
      attesterAddress,
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
    });
  }
});

module.exports = router;
