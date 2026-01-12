/**
 * Dashboard Service - Transparency & Analytics
 * 
 * Provides public transparency dashboard data:
 * - Attestation statistics
 * - Resolution metrics
 * - Officer performance
 * - Panchayat rankings
 */

const { ethers } = require('ethers');
const { config } = require('../config');
const logger = require('../utils/logger');
const easService = require('./easService');

class DashboardService {
  constructor() {
    this.provider = null;
    this.initialized = false;
    
    // In-memory metrics cache
    this.metricsCache = {
      totalAttestations: 0,
      totalResolutions: 0,
      averageResolutionTime: 0,
      attestationsByCategory: {},
      attestationsByPanchayat: {},
      dailyAttestations: [],
      monthlyTrends: [],
      topPerformers: [],
      lastUpdated: null,
    };
    
    // Resolution tracking
    this.resolutions = [];
  }

  /**
   * Initialize the dashboard service
   */
  async initialize() {
    if (this.initialized) {
      return;
    }

    try {
      this.provider = new ethers.JsonRpcProvider(config.blockchain.rpcUrl);
      this.initialized = true;
      logger.info('Dashboard service initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize dashboard service', { error: error.message });
      throw error;
    }
  }

  /**
   * Record a new attestation for metrics
   * @param {Object} attestationData - Attestation details
   */
  recordAttestation(attestationData) {
    const {
      uid,
      issueId,
      category,
      panchayatId,
      officerId,
      resolutionTimeHours,
      timestamp = Date.now(),
    } = attestationData;

    // Update totals
    this.metricsCache.totalAttestations++;
    this.metricsCache.totalResolutions++;

    // Update category stats
    if (category) {
      this.metricsCache.attestationsByCategory[category] = 
        (this.metricsCache.attestationsByCategory[category] || 0) + 1;
    }

    // Update panchayat stats
    if (panchayatId) {
      if (!this.metricsCache.attestationsByPanchayat[panchayatId]) {
        this.metricsCache.attestationsByPanchayat[panchayatId] = {
          total: 0,
          averageTime: 0,
          resolutionTimes: [],
        };
      }
      const pStats = this.metricsCache.attestationsByPanchayat[panchayatId];
      pStats.total++;
      if (resolutionTimeHours) {
        pStats.resolutionTimes.push(resolutionTimeHours);
        pStats.averageTime = pStats.resolutionTimes.reduce((a, b) => a + b, 0) / 
                             pStats.resolutionTimes.length;
      }
    }

    // Track resolution
    this.resolutions.push({
      uid,
      issueId,
      category,
      panchayatId,
      officerId,
      resolutionTimeHours,
      timestamp,
    });

    // Update average resolution time
    const timesWithData = this.resolutions.filter(r => r.resolutionTimeHours);
    if (timesWithData.length > 0) {
      this.metricsCache.averageResolutionTime = 
        timesWithData.reduce((sum, r) => sum + r.resolutionTimeHours, 0) / timesWithData.length;
    }

    // Update daily stats
    this.updateDailyStats(timestamp);

    this.metricsCache.lastUpdated = Date.now();
    
    logger.debug('Attestation recorded for metrics', { uid, category, panchayatId });
  }

  /**
   * Update daily attestation statistics
   */
  updateDailyStats(timestamp) {
    const date = new Date(timestamp).toISOString().split('T')[0];
    const existing = this.metricsCache.dailyAttestations.find(d => d.date === date);
    
    if (existing) {
      existing.count++;
    } else {
      this.metricsCache.dailyAttestations.push({ date, count: 1 });
      // Keep only last 30 days
      if (this.metricsCache.dailyAttestations.length > 30) {
        this.metricsCache.dailyAttestations.shift();
      }
    }
  }

  /**
   * Get public dashboard overview
   */
  async getOverview() {
    await this.initialize();

    return {
      summary: {
        totalAttestations: this.metricsCache.totalAttestations,
        totalResolutions: this.metricsCache.totalResolutions,
        averageResolutionTimeHours: Math.round(this.metricsCache.averageResolutionTime * 10) / 10,
        categoriesTracked: Object.keys(this.metricsCache.attestationsByCategory).length,
        panchayatsActive: Object.keys(this.metricsCache.attestationsByPanchayat).length,
      },
      lastUpdated: this.metricsCache.lastUpdated,
      network: {
        name: config.blockchain.network,
        chainId: config.blockchain.chainId,
        easContract: config.blockchain.easContract,
      },
    };
  }

  /**
   * Get attestations by category
   */
  async getAttestationsByCategory() {
    const categories = this.metricsCache.attestationsByCategory;
    const total = Object.values(categories).reduce((sum, count) => sum + count, 0);

    return {
      categories: Object.entries(categories).map(([name, count]) => ({
        name,
        count,
        percentage: total > 0 ? Math.round((count / total) * 100) : 0,
      })).sort((a, b) => b.count - a.count),
      total,
    };
  }

  /**
   * Get panchayat performance rankings
   */
  async getPanchayatRankings() {
    const panchayats = this.metricsCache.attestationsByPanchayat;

    return {
      rankings: Object.entries(panchayats).map(([id, stats]) => ({
        panchayatId: id,
        totalResolutions: stats.total,
        averageResolutionTimeHours: Math.round(stats.averageTime * 10) / 10,
        efficiencyScore: this.calculateEfficiencyScore(stats),
      })).sort((a, b) => b.efficiencyScore - a.efficiencyScore),
    };
  }

  /**
   * Calculate efficiency score (0-100)
   */
  calculateEfficiencyScore(stats) {
    // Score based on volume and speed
    const volumeScore = Math.min(stats.total / 10, 50); // Max 50 points for volume
    const speedScore = stats.averageTime > 0 
      ? Math.max(0, 50 - (stats.averageTime / 2)) // Faster = more points, max 50
      : 25; // Default if no time data
    
    return Math.round(volumeScore + speedScore);
  }

  /**
   * Get daily attestation trend
   * @param {number} days - Number of days to return
   */
  async getDailyTrend(days = 30) {
    const data = this.metricsCache.dailyAttestations.slice(-days);
    
    // Fill in missing days with 0
    const filledData = [];
    const today = new Date();
    
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      
      const existing = data.find(d => d.date === dateStr);
      filledData.push({
        date: dateStr,
        count: existing ? existing.count : 0,
      });
    }

    return {
      trend: filledData,
      total: filledData.reduce((sum, d) => sum + d.count, 0),
      average: Math.round(filledData.reduce((sum, d) => sum + d.count, 0) / days * 10) / 10,
    };
  }

  /**
   * Get recent attestations (public, anonymized)
   * @param {number} limit - Number of recent attestations
   */
  async getRecentAttestations(limit = 10) {
    const recent = this.resolutions
      .slice(-limit)
      .reverse()
      .map(r => ({
        uid: r.uid,
        category: r.category,
        panchayatId: r.panchayatId,
        resolutionTimeHours: r.resolutionTimeHours,
        timestamp: r.timestamp,
        // Anonymize officer ID
        officerHash: r.officerId ? 
          ethers.keccak256(ethers.toUtf8Bytes(r.officerId)).slice(0, 10) : null,
      }));

    return {
      attestations: recent,
      total: this.resolutions.length,
    };
  }

  /**
   * Get aggregate statistics
   */
  async getAggregateStats() {
    const categoryStats = await this.getAttestationsByCategory();
    const panchayatStats = await this.getPanchayatRankings();
    const dailyTrend = await this.getDailyTrend(7);

    return {
      overview: {
        totalAttestations: this.metricsCache.totalAttestations,
        averageResolutionTime: this.metricsCache.averageResolutionTime,
        activePanchayats: panchayatStats.rankings.length,
        categoriesTracked: categoryStats.categories.length,
      },
      topCategories: categoryStats.categories.slice(0, 5),
      topPanchayats: panchayatStats.rankings.slice(0, 5),
      weeklyTrend: dailyTrend,
      generatedAt: Date.now(),
    };
  }

  /**
   * Get verification statistics
   */
  async getVerificationStats() {
    // Track verification attempts (would be populated by verify endpoint)
    return {
      totalVerifications: 0,
      successfulVerifications: 0,
      failedVerifications: 0,
      verificationRate: 100,
      lastVerification: null,
    };
  }

  /**
   * Export metrics for IPFS archival
   */
  async exportMetricsForArchival() {
    const overview = await this.getOverview();
    const categories = await this.getAttestationsByCategory();
    const rankings = await this.getPanchayatRankings();
    const trend = await this.getDailyTrend(30);

    return {
      version: '1.0',
      exportedAt: Date.now(),
      network: config.blockchain.network,
      metrics: {
        overview: overview.summary,
        categories: categories.categories,
        panchayatRankings: rankings.rankings,
        dailyTrend: trend.trend,
      },
      signature: null, // Could be signed by service wallet
    };
  }

  /**
   * Health check for dashboard service
   */
  async healthCheck() {
    return {
      status: 'healthy',
      initialized: this.initialized,
      metricsCount: this.metricsCache.totalAttestations,
      lastUpdated: this.metricsCache.lastUpdated,
      cacheSize: {
        resolutions: this.resolutions.length,
        categories: Object.keys(this.metricsCache.attestationsByCategory).length,
        panchayats: Object.keys(this.metricsCache.attestationsByPanchayat).length,
      },
    };
  }
}

// Export singleton instance
module.exports = new DashboardService();
