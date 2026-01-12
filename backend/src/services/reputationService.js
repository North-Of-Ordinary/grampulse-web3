/**
 * Reputation Service - On-chain Reputation Management
 * 
 * Manages reputation tokens/NFTs for officers and volunteers:
 * - Issue reputation points
 * - Award achievement badges (Soulbound NFTs)
 * - Track performance metrics
 * - Query reputation scores
 */

const { ethers } = require('ethers');
const { config } = require('../config');
const logger = require('../utils/logger');

// Reputation Token ABI (ERC-5192 Soulbound compatible)
const REPUTATION_TOKEN_ABI = [
  // ERC-721 base functions
  'function balanceOf(address owner) view returns (uint256)',
  'function ownerOf(uint256 tokenId) view returns (address)',
  'function tokenURI(uint256 tokenId) view returns (string)',
  'function totalSupply() view returns (uint256)',
  
  // Reputation-specific functions
  'function mint(address to, uint256 tokenId, string uri) returns (bool)',
  'function getReputationScore(address account) view returns (uint256)',
  'function addReputationPoints(address account, uint256 points, string reason) returns (bool)',
  'function getBadges(address account) view returns (uint256[])',
  'function awardBadge(address account, uint256 badgeType, string metadata) returns (uint256)',
  
  // Soulbound functions (ERC-5192)
  'function locked(uint256 tokenId) view returns (bool)',
  
  // Events
  'event ReputationUpdated(address indexed account, uint256 newScore, string reason)',
  'event BadgeAwarded(address indexed account, uint256 indexed badgeId, uint256 badgeType)',
];

// Badge Types
const BadgeType = {
  QUICK_RESOLVER: 1,      // Resolved issues quickly
  COMMUNITY_HERO: 2,      // High community ratings
  CONSISTENCY_STAR: 3,    // Consistent performance
  FIRST_RESPONDER: 4,     // First to respond to issues
  MILESTONE_100: 5,       // 100 issues resolved
  MILESTONE_500: 6,       // 500 issues resolved
  MILESTONE_1000: 7,      // 1000 issues resolved
  TOP_PERFORMER: 8,       // Monthly top performer
  INNOVATION_AWARD: 9,    // Innovative solutions
  CITIZEN_FAVORITE: 10,   // Most liked by citizens
};

// Reputation Point Values
const ReputationPoints = {
  ISSUE_RESOLVED: 10,
  QUICK_RESOLUTION: 5,    // Bonus for fast resolution
  POSITIVE_FEEDBACK: 3,
  NEGATIVE_FEEDBACK: -5,
  FIRST_RESPONSE: 2,
  COMMUNITY_EVENT: 15,
  TRAINING_COMPLETED: 20,
};

class ReputationService {
  constructor() {
    this.provider = null;
    this.wallet = null;
    this.reputationToken = null;
    this.initialized = false;
    
    // In-memory cache for off-chain reputation (when contract not deployed)
    this.reputationCache = new Map();
    this.badgeCache = new Map();
  }

  /**
   * Initialize the reputation service
   */
  async initialize() {
    if (this.initialized) {
      return;
    }

    try {
      // Setup provider
      this.provider = new ethers.JsonRpcProvider(config.blockchain.rpcUrl);
      
      // Setup wallet
      this.wallet = new ethers.Wallet(config.blockchain.privateKey, this.provider);
      
      // Setup Reputation Token contract
      const tokenAddress = config.blockchain.reputationTokenAddress;
      if (tokenAddress && tokenAddress !== '0x0000000000000000000000000000000000000000') {
        this.reputationToken = new ethers.Contract(tokenAddress, REPUTATION_TOKEN_ABI, this.wallet);
        logger.info('Reputation token contract initialized', { address: tokenAddress });
      } else {
        logger.warn('Reputation token address not configured - using off-chain mode');
      }

      this.initialized = true;
      logger.info('Reputation service initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize reputation service', { error: error.message });
      throw error;
    }
  }

  /**
   * Add reputation points to an account
   * @param {Object} data - Reputation update data
   */
  async addReputationPoints(data) {
    await this.initialize();

    const { 
      address, 
      points, 
      reason, 
      issueId = null,
      category = 'general' 
    } = data;

    try {
      logger.info('Adding reputation points', { address, points, reason });

      // If contract is deployed, use on-chain
      if (this.reputationToken) {
        const tx = await this.reputationToken.addReputationPoints(
          address,
          points,
          reason
        );
        const receipt = await tx.wait();

        return {
          success: true,
          address,
          pointsAdded: points,
          reason,
          txHash: receipt.hash,
          onChain: true,
        };
      }

      // Off-chain fallback
      const currentScore = this.reputationCache.get(address) || 0;
      const newScore = Math.max(0, currentScore + points); // Prevent negative
      this.reputationCache.set(address, newScore);

      logger.info('Reputation updated (off-chain)', { address, newScore });

      return {
        success: true,
        address,
        pointsAdded: points,
        newScore,
        reason,
        issueId,
        category,
        onChain: false,
        timestamp: Date.now(),
      };
    } catch (error) {
      logger.error('Failed to add reputation points', { error: error.message, address });
      throw error;
    }
  }

  /**
   * Get reputation score for an account
   * @param {string} address - Account address or user ID
   */
  async getReputationScore(address) {
    await this.initialize();

    try {
      // If contract is deployed, use on-chain
      if (this.reputationToken) {
        const score = await this.reputationToken.getReputationScore(address);
        return {
          address,
          score: score.toString(),
          onChain: true,
        };
      }

      // Off-chain fallback
      const score = this.reputationCache.get(address) || 0;
      return {
        address,
        score,
        onChain: false,
      };
    } catch (error) {
      logger.error('Failed to get reputation score', { error: error.message, address });
      throw error;
    }
  }

  /**
   * Award a badge to an account
   * @param {Object} data - Badge award data
   */
  async awardBadge(data) {
    await this.initialize();

    const { 
      address, 
      badgeType, 
      metadata = {},
      reason = '' 
    } = data;

    try {
      const badgeMetadata = JSON.stringify({
        type: badgeType,
        typeName: Object.keys(BadgeType).find(k => BadgeType[k] === badgeType) || 'UNKNOWN',
        awardedAt: Date.now(),
        reason,
        ...metadata,
      });

      logger.info('Awarding badge', { address, badgeType });

      // If contract is deployed, use on-chain
      if (this.reputationToken) {
        const tx = await this.reputationToken.awardBadge(
          address,
          badgeType,
          badgeMetadata
        );
        const receipt = await tx.wait();

        // Extract badge ID from event
        const badgeEvent = receipt.logs.find(
          log => log.fragment?.name === 'BadgeAwarded'
        );
        const badgeId = badgeEvent?.args?.badgeId?.toString() || Date.now().toString();

        return {
          success: true,
          address,
          badgeId,
          badgeType,
          metadata: badgeMetadata,
          txHash: receipt.hash,
          onChain: true,
        };
      }

      // Off-chain fallback
      const badges = this.badgeCache.get(address) || [];
      const badgeId = `badge_${Date.now()}_${badgeType}`;
      badges.push({
        id: badgeId,
        type: badgeType,
        metadata: badgeMetadata,
        awardedAt: Date.now(),
      });
      this.badgeCache.set(address, badges);

      logger.info('Badge awarded (off-chain)', { address, badgeId });

      return {
        success: true,
        address,
        badgeId,
        badgeType,
        metadata: badgeMetadata,
        onChain: false,
        timestamp: Date.now(),
      };
    } catch (error) {
      logger.error('Failed to award badge', { error: error.message, address });
      throw error;
    }
  }

  /**
   * Get all badges for an account
   * @param {string} address - Account address or user ID
   */
  async getBadges(address) {
    await this.initialize();

    try {
      // If contract is deployed, use on-chain
      if (this.reputationToken) {
        const badgeIds = await this.reputationToken.getBadges(address);
        const badges = await Promise.all(
          badgeIds.map(async (id) => {
            const uri = await this.reputationToken.tokenURI(id);
            return { id: id.toString(), uri };
          })
        );
        return {
          address,
          badges,
          onChain: true,
        };
      }

      // Off-chain fallback
      const badges = this.badgeCache.get(address) || [];
      return {
        address,
        badges,
        onChain: false,
      };
    } catch (error) {
      logger.error('Failed to get badges', { error: error.message, address });
      throw error;
    }
  }

  /**
   * Calculate and award reputation for issue resolution
   * @param {Object} resolutionData - Resolution details
   */
  async processResolutionReputation(resolutionData) {
    const {
      resolverAddress,
      issueId,
      resolutionTime, // in hours
      rating = 5, // 1-5 scale
      isFirstResponder = false,
    } = resolutionData;

    let totalPoints = ReputationPoints.ISSUE_RESOLVED;
    const reasons = ['Issue resolved'];

    // Quick resolution bonus (under 24 hours)
    if (resolutionTime && resolutionTime < 24) {
      totalPoints += ReputationPoints.QUICK_RESOLUTION;
      reasons.push('Quick resolution bonus');
    }

    // First responder bonus
    if (isFirstResponder) {
      totalPoints += ReputationPoints.FIRST_RESPONSE;
      reasons.push('First responder');
    }

    // Rating adjustment
    if (rating >= 4) {
      totalPoints += ReputationPoints.POSITIVE_FEEDBACK;
      reasons.push('Positive feedback');
    } else if (rating <= 2) {
      totalPoints += ReputationPoints.NEGATIVE_FEEDBACK;
      reasons.push('Negative feedback');
    }

    // Add reputation points
    const result = await this.addReputationPoints({
      address: resolverAddress,
      points: totalPoints,
      reason: reasons.join(', '),
      issueId,
      category: 'resolution',
    });

    // Check for milestone badges
    await this.checkMilestoneBadges(resolverAddress);

    return {
      ...result,
      breakdown: {
        base: ReputationPoints.ISSUE_RESOLVED,
        quickBonus: resolutionTime < 24 ? ReputationPoints.QUICK_RESOLUTION : 0,
        firstResponder: isFirstResponder ? ReputationPoints.FIRST_RESPONSE : 0,
        feedback: rating >= 4 ? ReputationPoints.POSITIVE_FEEDBACK : 
                  rating <= 2 ? ReputationPoints.NEGATIVE_FEEDBACK : 0,
        total: totalPoints,
      },
    };
  }

  /**
   * Check and award milestone badges
   * @param {string} address - Account address
   */
  async checkMilestoneBadges(address) {
    const { score } = await this.getReputationScore(address);
    const { badges } = await this.getBadges(address);
    const badgeTypes = badges.map(b => b.type || JSON.parse(b.metadata || '{}').type);

    const milestones = [
      { score: 1000, badge: BadgeType.MILESTONE_100, name: '100 Issues Milestone' },
      { score: 5000, badge: BadgeType.MILESTONE_500, name: '500 Issues Milestone' },
      { score: 10000, badge: BadgeType.MILESTONE_1000, name: '1000 Issues Milestone' },
    ];

    for (const milestone of milestones) {
      if (score >= milestone.score && !badgeTypes.includes(milestone.badge)) {
        await this.awardBadge({
          address,
          badgeType: milestone.badge,
          reason: milestone.name,
          metadata: { scoreAtAward: score },
        });
      }
    }
  }

  /**
   * Get leaderboard
   * @param {number} limit - Number of top performers to return
   */
  async getLeaderboard(limit = 10) {
    await this.initialize();

    try {
      // Off-chain leaderboard
      const entries = Array.from(this.reputationCache.entries())
        .map(([address, score]) => ({ address, score }))
        .sort((a, b) => b.score - a.score)
        .slice(0, limit);

      return {
        leaderboard: entries,
        updatedAt: Date.now(),
      };
    } catch (error) {
      logger.error('Failed to get leaderboard', { error: error.message });
      throw error;
    }
  }

  /**
   * Get badge type definitions
   */
  getBadgeTypes() {
    return Object.entries(BadgeType).map(([name, id]) => ({
      id,
      name,
      displayName: name.split('_').map(w => 
        w.charAt(0) + w.slice(1).toLowerCase()
      ).join(' '),
    }));
  }

  /**
   * Get reputation point values
   */
  getReputationPointValues() {
    return ReputationPoints;
  }
}

// Export singleton instance
module.exports = new ReputationService();
