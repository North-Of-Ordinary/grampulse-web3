/**
 * Batch Attestation Routes - Advanced Attestation Operations
 * 
 * Endpoints:
 * - POST /batch/attest - Create multiple attestations
 * - POST /batch/revoke - Revoke an attestation
 * - POST /batch/revoke-many - Revoke multiple attestations
 * - GET /batch/revoked/:uid - Check if attestation is revoked
 * - POST /batch/referenced - Create a referenced attestation
 * - GET /batch/chain/:uid - Get attestation chain
 * - GET /batch/estimate - Estimate gas for batch
 * - GET /batch/schema - Get schema details
 */

const express = require('express');
const router = express.Router();
const batchAttestationService = require('../services/batchAttestationService');
const dashboardService = require('../services/dashboardService');
const reputationService = require('../services/reputationService');
const { authenticateApiKey, validateRequest, asyncHandler } = require('../middleware/auth');
const logger = require('../utils/logger');

/**
 * Create multiple attestations in a batch
 * POST /batch/attest
 */
router.post('/attest', authenticateApiKey, validateRequest([
  'attestations',
]), asyncHandler(async (req, res) => {
  const { attestations } = req.body;

  if (!Array.isArray(attestations)) {
    return res.status(400).json({
      success: false,
      error: 'attestations must be an array',
    });
  }

  logger.info('Creating batch attestations', { count: attestations.length });

  const result = await batchAttestationService.createBatchAttestations(attestations);

  // Record each for dashboard metrics
  attestations.forEach((att, index) => {
    dashboardService.recordAttestation({
      uid: result.uids[index],
      issueId: att.issueId,
      category: att.category,
      panchayatId: att.panchayatId,
      officerId: att.resolver,
    });
  });

  res.status(201).json({
    success: true,
    message: `${result.count} attestations created`,
    data: result,
  });
}));

/**
 * Revoke a single attestation
 * POST /batch/revoke
 */
router.post('/revoke', authenticateApiKey, validateRequest([
  'uid',
]), asyncHandler(async (req, res) => {
  const { uid, reason, schemaUid } = req.body;

  logger.info('Revoking attestation', { uid, reason });

  const result = await batchAttestationService.revokeAttestation(uid, {
    reason,
    schemaUid,
  });

  res.status(200).json({
    success: true,
    message: 'Attestation revoked',
    data: result,
  });
}));

/**
 * Revoke multiple attestations
 * POST /batch/revoke-many
 */
router.post('/revoke-many', authenticateApiKey, validateRequest([
  'uids',
]), asyncHandler(async (req, res) => {
  const { uids, reason, schemaUid } = req.body;

  if (!Array.isArray(uids)) {
    return res.status(400).json({
      success: false,
      error: 'uids must be an array',
    });
  }

  logger.info('Batch revoking attestations', { count: uids.length });

  const result = await batchAttestationService.batchRevokeAttestations(uids, {
    reason,
    schemaUid,
  });

  res.status(200).json({
    success: true,
    message: `${result.count} attestations revoked`,
    data: result,
  });
}));

/**
 * Check if attestation is revoked
 * GET /batch/revoked/:uid
 */
router.get('/revoked/:uid', asyncHandler(async (req, res) => {
  const { uid } = req.params;

  const result = await batchAttestationService.isRevoked(uid);

  res.status(200).json({
    success: true,
    data: result,
  });
}));

/**
 * Create a referenced attestation
 * POST /batch/referenced
 */
router.post('/referenced', authenticateApiKey, validateRequest([
  'parentUid',
  'issueId',
]), asyncHandler(async (req, res) => {
  const { parentUid, ...data } = req.body;

  logger.info('Creating referenced attestation', { parentUid });

  const result = await batchAttestationService.createReferencedAttestation(data, parentUid);

  // Record for metrics
  dashboardService.recordAttestation({
    uid: result.uid,
    issueId: data.issueId,
    category: data.category,
    panchayatId: data.panchayatId,
  });

  res.status(201).json({
    success: true,
    message: 'Referenced attestation created',
    data: result,
  });
}));

/**
 * Get attestation chain
 * GET /batch/chain/:uid
 */
router.get('/chain/:uid', asyncHandler(async (req, res) => {
  const { uid } = req.params;

  const chain = await batchAttestationService.getAttestationChain(uid);

  res.status(200).json({
    success: true,
    data: chain,
  });
}));

/**
 * Estimate gas for batch operation
 * GET /batch/estimate
 */
router.get('/estimate', asyncHandler(async (req, res) => {
  const { count } = req.query;

  if (!count) {
    return res.status(400).json({
      success: false,
      error: 'count parameter is required',
    });
  }

  const estimate = await batchAttestationService.estimateBatchGas(parseInt(count));

  res.status(200).json({
    success: true,
    data: estimate,
  });
}));

/**
 * Get schema details
 * GET /batch/schema
 */
router.get('/schema', asyncHandler(async (req, res) => {
  const schema = await batchAttestationService.getSchemaDetails();

  res.status(200).json({
    success: true,
    data: schema,
  });
}));

/**
 * Create attestation with full workflow (attest + reputation + metrics)
 * POST /batch/full-workflow
 */
router.post('/full-workflow', authenticateApiKey, validateRequest([
  'issueId',
  'resolverAddress',
]), asyncHandler(async (req, res) => {
  const {
    issueId,
    resolverAddress,
    resolutionHash,
    category,
    panchayatId,
    ipfsCid,
    resolutionTimeHours,
    rating,
    isFirstResponder,
  } = req.body;

  logger.info('Processing full attestation workflow', { issueId, resolverAddress });

  // Step 1: Create attestation
  const attestations = [{
    issueId,
    resolutionHash: resolutionHash || '',
    resolver: resolverAddress,
    category: category || '',
    panchayatId: panchayatId || '',
    ipfsCid: ipfsCid || '',
  }];

  const attestResult = await batchAttestationService.createBatchAttestations(attestations);
  const uid = attestResult.uids[0];

  // Step 2: Record for dashboard metrics
  dashboardService.recordAttestation({
    uid,
    issueId,
    category,
    panchayatId,
    officerId: resolverAddress,
    resolutionTimeHours: resolutionTimeHours ? parseFloat(resolutionTimeHours) : null,
  });

  // Step 3: Process reputation
  const reputationResult = await reputationService.processResolutionReputation({
    resolverAddress,
    issueId,
    resolutionTime: resolutionTimeHours ? parseFloat(resolutionTimeHours) : null,
    rating: rating ? parseInt(rating) : 5,
    isFirstResponder: isFirstResponder === true,
  });

  res.status(201).json({
    success: true,
    message: 'Full workflow completed',
    data: {
      attestation: {
        uid,
        txHash: attestResult.txHash,
      },
      reputation: reputationResult,
    },
  });
}));

module.exports = router;
