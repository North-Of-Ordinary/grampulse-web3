/**
 * Governance Routes - DAO API Endpoints
 * 
 * Endpoints:
 * - POST /governance/proposal - Create a proposal
 * - POST /governance/vote - Cast a vote
 * - GET /governance/proposal/:id - Get proposal details
 * - GET /governance/params - Get governance parameters
 * - POST /governance/execute - Execute a passed proposal
 */

const express = require('express');
const router = express.Router();
const governanceService = require('../services/governanceService');
const { authenticateApiKey, validateRequest, asyncHandler } = require('../middleware/auth');
const logger = require('../utils/logger');

/**
 * Create a new proposal
 * POST /governance/proposal
 */
router.post('/proposal', authenticateApiKey, validateRequest([
  'title',
  'description',
  'category',
]), asyncHandler(async (req, res) => {
  const {
    title,
    description,
    category,
    budgetAmount,
    targets,
    values,
    calldatas,
    proposerId,
    panchayatId,
  } = req.body;

  logger.info('Creating governance proposal', { title, category, proposerId });

  const result = await governanceService.createProposal({
    title,
    description,
    category,
    budgetAmount,
    targets,
    values,
    calldatas,
    proposerId,
    panchayatId,
  });

  res.status(201).json({
    success: true,
    message: 'Proposal created successfully',
    data: result,
  });
}));

/**
 * Cast a vote on a proposal
 * POST /governance/vote
 */
router.post('/vote', authenticateApiKey, validateRequest([
  'proposalId',
  'support',
]), asyncHandler(async (req, res) => {
  const { proposalId, support, reason, voterId } = req.body;

  logger.info('Casting vote', { proposalId, support, voterId });

  const result = await governanceService.castVote(proposalId, {
    support,
    reason,
    voterId,
  });

  res.status(200).json({
    success: true,
    message: 'Vote cast successfully',
    data: result,
  });
}));

/**
 * Get proposal details
 * GET /governance/proposal/:id
 */
router.get('/proposal/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const proposal = await governanceService.getProposal(id);

  res.status(200).json({
    success: true,
    data: proposal,
  });
}));

/**
 * Get governance parameters
 * GET /governance/params
 */
router.get('/params', asyncHandler(async (req, res) => {
  const params = await governanceService.getGovernanceParams();

  res.status(200).json({
    success: true,
    data: params,
  });
}));

/**
 * Execute a passed proposal
 * POST /governance/execute
 */
router.post('/execute', authenticateApiKey, validateRequest([
  'proposalId',
  'targets',
  'values',
  'calldatas',
  'description',
]), asyncHandler(async (req, res) => {
  const { proposalId, targets, values, calldatas, description } = req.body;

  logger.info('Executing proposal', { proposalId });

  const result = await governanceService.executeProposal(proposalId, {
    targets,
    values,
    calldatas,
    description,
  });

  res.status(200).json({
    success: true,
    message: 'Proposal executed successfully',
    data: result,
  });
}));

/**
 * Check if address has voted
 * GET /governance/voted/:proposalId/:address
 */
router.get('/voted/:proposalId/:address', asyncHandler(async (req, res) => {
  const { proposalId, address } = req.params;

  const result = await governanceService.hasVoted(proposalId, address);

  res.status(200).json({
    success: true,
    data: result,
  });
}));

/**
 * Get voting power for address
 * GET /governance/voting-power/:address
 */
router.get('/voting-power/:address', asyncHandler(async (req, res) => {
  const { address } = req.params;
  const { blockNumber } = req.query;

  const result = await governanceService.getVotingPower(
    address, 
    blockNumber ? parseInt(blockNumber) : null
  );

  res.status(200).json({
    success: true,
    data: result,
  });
}));

module.exports = router;
