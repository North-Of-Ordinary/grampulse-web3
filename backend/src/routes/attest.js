/**
 * GramPulse Attestation Routes
 * 
 * Endpoints for creating attestations on the blockchain
 */

const express = require('express');
const { v4: uuidv4 } = require('uuid');
const easService = require('../services/easService');
const { authenticateApiKey, validateRequest } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

/**
 * POST /attest/resolution
 * 
 * Creates an on-chain attestation for a resolved grievance
 * 
 * Body:
 * - grievanceId (required): Firebase document ID
 * - villageId (required): Village identifier
 * - resolverRole (required): 'officer' or 'volunteer'
 * - ipfsHash (optional): IPFS CID of proof
 * 
 * Response:
 * - attestationUid: The on-chain attestation UID
 * - transactionHash: Ethereum transaction hash
 * - explorerUrl: Link to view on block explorer
 */
router.post(
  '/resolution',
  authenticateApiKey,
  validateRequest(['grievanceId', 'villageId', 'resolverRole']),
  async (req, res, next) => {
    const requestId = uuidv4();
    const { grievanceId, villageId, resolverRole, ipfsHash } = req.body;

    logger.info('Resolution attestation request', {
      requestId,
      grievanceId,
      villageId,
      resolverRole,
      hasIpfsHash: !!ipfsHash,
    });

    try {
      // Validate resolver role
      const validRoles = ['officer', 'volunteer', 'citizen'];
      if (!validRoles.includes(resolverRole.toLowerCase())) {
        return res.status(400).json({
          error: 'Bad Request',
          message: `Invalid resolverRole. Must be one of: ${validRoles.join(', ')}`,
        });
      }

      // Create the attestation
      const result = await easService.createResolutionAttestation({
        grievanceId,
        villageId,
        resolverRole: resolverRole.toLowerCase(),
        ipfsHash: ipfsHash || '',
      });

      logger.info('Resolution attestation created', {
        requestId,
        attestationUid: result.attestationUid,
        transactionHash: result.transactionHash,
      });

      res.status(201).json({
        success: true,
        requestId,
        data: {
          attestationUid: result.attestationUid,
          transactionHash: result.transactionHash,
          timestamp: result.timestamp,
          explorerUrl: result.explorerUrl,
        },
      });

    } catch (error) {
      logger.error('Failed to create resolution attestation', {
        requestId,
        error: error.message,
        grievanceId,
      });

      // Check for specific error types
      if (error.message.includes('insufficient funds')) {
        return res.status(503).json({
          error: 'Service Unavailable',
          message: 'Attestation service temporarily unavailable (insufficient gas)',
          requestId,
        });
      }

      next(error);
    }
  }
);

/**
 * POST /attest/reputation
 * 
 * Creates a reputation boost attestation for a contributor
 * 
 * Body:
 * - userId (required): Firebase user ID
 * - villageId (required): Village identifier
 * - category (required): Contribution category
 * - points (required): Points awarded
 * 
 * Response:
 * - attestationUid: The on-chain attestation UID
 */
router.post(
  '/reputation',
  authenticateApiKey,
  validateRequest(['userId', 'villageId', 'category', 'points']),
  async (req, res, next) => {
    const requestId = uuidv4();

    logger.info('Reputation attestation request', {
      requestId,
      ...req.body,
    });

    // TODO: Implement reputation schema and attestation
    // This is a placeholder for Phase 5

    res.status(501).json({
      error: 'Not Implemented',
      message: 'Reputation attestations will be available in Phase 5',
      requestId,
    });
  }
);

/**
 * POST /attest/vsi
 * 
 * Creates a Village Sustainability Index (VSI) attestation
 * 
 * Body:
 * - villageId (required): Village identifier
 * - month (required): Month (1-12)
 * - year (required): Year
 * - scores (required): Object with category scores
 * 
 * Response:
 * - attestationUid: The on-chain attestation UID
 */
router.post(
  '/vsi',
  authenticateApiKey,
  validateRequest(['villageId', 'month', 'year', 'scores']),
  async (req, res, next) => {
    const requestId = uuidv4();

    logger.info('VSI attestation request', {
      requestId,
      villageId: req.body.villageId,
      month: req.body.month,
      year: req.body.year,
    });

    // TODO: Implement VSI schema and attestation
    // This is a placeholder for Phase 6

    res.status(501).json({
      error: 'Not Implemented',
      message: 'VSI attestations will be available in Phase 6',
      requestId,
    });
  }
);

module.exports = router;
