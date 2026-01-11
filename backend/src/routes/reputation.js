/**
 * Reputation Routes - Reputation System API Endpoints
 * 
 * Endpoints:
 * - POST /reputation/points - Add reputation points
 * - GET /reputation/score/:address - Get reputation score
 * - POST /reputation/badge - Award a badge
 * - GET /reputation/badges/:address - Get badges for address
 * - POST /reputation/resolution - Process resolution reputation
 * - GET /reputation/leaderboard - Get top performers
 * - GET /reputation/badge-types - Get badge type definitions
 */

const express = require('express');
const router = express.Router();
const reputationService = require('../services/reputationService');
const { authenticateApiKey, validateRequest, asyncHandler } = require('../middleware/auth');
const logger = require('../utils/logger');

/**
 * Add reputation points to an account
 * POST /reputation/points
 */
router.post('/points', authenticateApiKey, validateRequest([
  'address',
  'points',
  'reason',
]), asyncHandler(async (req, res) => {
  const { address, points, reason, issueId, category } = req.body;

  logger.info('Adding reputation points', { address, points });

  const result = await reputationService.addReputationPoints({
    address,
    points: parseInt(points),
    reason,
    issueId,
    category,
  });

  res.status(200).json({
    success: true,
    message: 'Reputation points added',
    data: result,
  });
}));

/**
 * Get reputation score for an address
 * GET /reputation/score/:address
 */
router.get('/score/:address', asyncHandler(async (req, res) => {
  const { address } = req.params;

  const result = await reputationService.getReputationScore(address);

  res.status(200).json({
    success: true,
    data: result,
  });
}));

/**
 * Award a badge to an account
 * POST /reputation/badge
 */
router.post('/badge', authenticateApiKey, validateRequest([
  'address',
  'badgeType',
]), asyncHandler(async (req, res) => {
  const { address, badgeType, metadata, reason } = req.body;

  logger.info('Awarding badge', { address, badgeType });

  const result = await reputationService.awardBadge({
    address,
    badgeType: parseInt(badgeType),
    metadata,
    reason,
  });

  res.status(201).json({
    success: true,
    message: 'Badge awarded',
    data: result,
  });
}));

/**
 * Get badges for an address
 * GET /reputation/badges/:address
 */
router.get('/badges/:address', asyncHandler(async (req, res) => {
  const { address } = req.params;

  const result = await reputationService.getBadges(address);

  res.status(200).json({
    success: true,
    data: result,
  });
}));

/**
 * Process reputation for issue resolution
 * POST /reputation/resolution
 */
router.post('/resolution', authenticateApiKey, validateRequest([
  'resolverAddress',
  'issueId',
]), asyncHandler(async (req, res) => {
  const { 
    resolverAddress, 
    issueId, 
    resolutionTime, 
    rating,
    isFirstResponder 
  } = req.body;

  logger.info('Processing resolution reputation', { resolverAddress, issueId });

  const result = await reputationService.processResolutionReputation({
    resolverAddress,
    issueId,
    resolutionTime: resolutionTime ? parseFloat(resolutionTime) : null,
    rating: rating ? parseInt(rating) : 5,
    isFirstResponder: isFirstResponder === true,
  });

  res.status(200).json({
    success: true,
    message: 'Resolution reputation processed',
    data: result,
  });
}));

/**
 * Get leaderboard
 * GET /reputation/leaderboard
 */
router.get('/leaderboard', asyncHandler(async (req, res) => {
  const { limit } = req.query;

  const result = await reputationService.getLeaderboard(
    limit ? parseInt(limit) : 10
  );

  res.status(200).json({
    success: true,
    data: result,
  });
}));

/**
 * Get badge type definitions
 * GET /reputation/badge-types
 */
router.get('/badge-types', asyncHandler(async (req, res) => {
  const badgeTypes = reputationService.getBadgeTypes();

  res.status(200).json({
    success: true,
    data: badgeTypes,
  });
}));

/**
 * Get reputation point values
 * GET /reputation/point-values
 */
router.get('/point-values', asyncHandler(async (req, res) => {
  const pointValues = reputationService.getReputationPointValues();

  res.status(200).json({
    success: true,
    data: pointValues,
  });
}));

module.exports = router;
