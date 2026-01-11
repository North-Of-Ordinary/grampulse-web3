/**
 * Dashboard Routes - Public Transparency Dashboard API
 * 
 * All routes are public (no authentication required)
 * 
 * Endpoints:
 * - GET /dashboard/overview - Get dashboard overview
 * - GET /dashboard/categories - Get attestations by category
 * - GET /dashboard/panchayats - Get panchayat rankings
 * - GET /dashboard/trend - Get daily attestation trend
 * - GET /dashboard/recent - Get recent attestations
 * - GET /dashboard/stats - Get aggregate statistics
 * - GET /dashboard/export - Export metrics for archival
 * - GET /dashboard/health - Health check
 */

const express = require('express');
const router = express.Router();
const dashboardService = require('../services/dashboardService');
const { asyncHandler } = require('../middleware/auth');
const logger = require('../utils/logger');

/**
 * Get dashboard overview
 * GET /dashboard/overview
 */
router.get('/overview', asyncHandler(async (req, res) => {
  const overview = await dashboardService.getOverview();

  res.status(200).json({
    success: true,
    data: overview,
  });
}));

/**
 * Get attestations by category
 * GET /dashboard/categories
 */
router.get('/categories', asyncHandler(async (req, res) => {
  const categories = await dashboardService.getAttestationsByCategory();

  res.status(200).json({
    success: true,
    data: categories,
  });
}));

/**
 * Get panchayat performance rankings
 * GET /dashboard/panchayats
 */
router.get('/panchayats', asyncHandler(async (req, res) => {
  const rankings = await dashboardService.getPanchayatRankings();

  res.status(200).json({
    success: true,
    data: rankings,
  });
}));

/**
 * Get daily attestation trend
 * GET /dashboard/trend
 */
router.get('/trend', asyncHandler(async (req, res) => {
  const { days } = req.query;

  const trend = await dashboardService.getDailyTrend(
    days ? parseInt(days) : 30
  );

  res.status(200).json({
    success: true,
    data: trend,
  });
}));

/**
 * Get recent attestations (anonymized)
 * GET /dashboard/recent
 */
router.get('/recent', asyncHandler(async (req, res) => {
  const { limit } = req.query;

  const recent = await dashboardService.getRecentAttestations(
    limit ? parseInt(limit) : 10
  );

  res.status(200).json({
    success: true,
    data: recent,
  });
}));

/**
 * Get aggregate statistics
 * GET /dashboard/stats
 */
router.get('/stats', asyncHandler(async (req, res) => {
  const stats = await dashboardService.getAggregateStats();

  res.status(200).json({
    success: true,
    data: stats,
  });
}));

/**
 * Get verification statistics
 * GET /dashboard/verifications
 */
router.get('/verifications', asyncHandler(async (req, res) => {
  const stats = await dashboardService.getVerificationStats();

  res.status(200).json({
    success: true,
    data: stats,
  });
}));

/**
 * Export metrics for IPFS archival
 * GET /dashboard/export
 */
router.get('/export', asyncHandler(async (req, res) => {
  const exported = await dashboardService.exportMetricsForArchival();

  res.status(200).json({
    success: true,
    data: exported,
  });
}));

/**
 * Health check for dashboard service
 * GET /dashboard/health
 */
router.get('/health', asyncHandler(async (req, res) => {
  const health = await dashboardService.healthCheck();

  res.status(200).json({
    success: true,
    data: health,
  });
}));

/**
 * Record attestation for metrics (internal use)
 * POST /dashboard/record
 * Note: This would typically be called internally after creating an attestation
 */
router.post('/record', asyncHandler(async (req, res) => {
  const {
    uid,
    issueId,
    category,
    panchayatId,
    officerId,
    resolutionTimeHours,
  } = req.body;

  dashboardService.recordAttestation({
    uid,
    issueId,
    category,
    panchayatId,
    officerId,
    resolutionTimeHours: resolutionTimeHours ? parseFloat(resolutionTimeHours) : null,
  });

  res.status(200).json({
    success: true,
    message: 'Attestation recorded for metrics',
  });
}));

module.exports = router;
