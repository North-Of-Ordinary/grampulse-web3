/**
 * Governance Service - DAO Operations for Panchayat
 * 
 * Handles on-chain governance operations including:
 * - Creating proposals
 * - Voting on proposals
 * - Executing passed proposals
 * - Querying governance state
 */

const { ethers } = require('ethers');
const config = require('../config');
const logger = require('../utils/logger');

// Governor Contract ABI (OpenZeppelin Governor compatible)
const GOVERNOR_ABI = [
  // Proposal functions
  'function propose(address[] targets, uint256[] values, bytes[] calldatas, string description) returns (uint256)',
  'function queue(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) returns (uint256)',
  'function execute(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) returns (uint256)',
  'function cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) returns (uint256)',
  
  // Voting functions
  'function castVote(uint256 proposalId, uint8 support) returns (uint256)',
  'function castVoteWithReason(uint256 proposalId, uint8 support, string reason) returns (uint256)',
  'function castVoteWithReasonAndParams(uint256 proposalId, uint8 support, string reason, bytes params) returns (uint256)',
  
  // View functions
  'function state(uint256 proposalId) view returns (uint8)',
  'function proposalSnapshot(uint256 proposalId) view returns (uint256)',
  'function proposalDeadline(uint256 proposalId) view returns (uint256)',
  'function proposalVotes(uint256 proposalId) view returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes)',
  'function hasVoted(uint256 proposalId, address account) view returns (bool)',
  'function getVotes(address account, uint256 blockNumber) view returns (uint256)',
  'function quorum(uint256 blockNumber) view returns (uint256)',
  'function votingDelay() view returns (uint256)',
  'function votingPeriod() view returns (uint256)',
  'function proposalThreshold() view returns (uint256)',
  'function name() view returns (string)',
  
  // Events
  'event ProposalCreated(uint256 proposalId, address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 startBlock, uint256 endBlock, string description)',
  'event ProposalCanceled(uint256 proposalId)',
  'event ProposalExecuted(uint256 proposalId)',
  'event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason)',
];

// Proposal States
const ProposalState = {
  0: 'Pending',
  1: 'Active',
  2: 'Canceled',
  3: 'Defeated',
  4: 'Succeeded',
  5: 'Queued',
  6: 'Expired',
  7: 'Executed',
};

// Vote Types
const VoteType = {
  Against: 0,
  For: 1,
  Abstain: 2,
};

class GovernanceService {
  constructor() {
    this.provider = null;
    this.wallet = null;
    this.governor = null;
    this.initialized = false;
  }

  /**
   * Initialize the governance service
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
      
      // Setup Governor contract
      const governorAddress = config.blockchain.governorAddress;
      if (governorAddress && governorAddress !== '0x0000000000000000000000000000000000000000') {
        this.governor = new ethers.Contract(governorAddress, GOVERNOR_ABI, this.wallet);
        logger.info('Governor contract initialized', { address: governorAddress });
      } else {
        logger.warn('Governor address not configured - governance features disabled');
      }

      this.initialized = true;
      logger.info('Governance service initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize governance service', { error: error.message });
      throw error;
    }
  }

  /**
   * Create a new proposal
   * @param {Object} proposalData - Proposal details
   */
  async createProposal(proposalData) {
    await this.initialize();

    if (!this.governor) {
      throw new Error('Governor contract not configured');
    }

    const {
      title,
      description,
      category,
      budgetAmount,
      targets = [],
      values = [],
      calldatas = [],
      proposerId,
      panchayatId,
    } = proposalData;

    try {
      // Build full description with metadata
      const fullDescription = JSON.stringify({
        title,
        description,
        category,
        budgetAmount,
        proposerId,
        panchayatId,
        timestamp: Date.now(),
        version: '1.0',
      });

      // If no specific on-chain actions, create a signaling proposal
      const finalTargets = targets.length > 0 ? targets : [this.governor.target];
      const finalValues = values.length > 0 ? values : [0];
      const finalCalldatas = calldatas.length > 0 ? calldatas : ['0x'];

      logger.info('Creating proposal', { title, category });

      const tx = await this.governor.propose(
        finalTargets,
        finalValues,
        finalCalldatas,
        fullDescription
      );

      const receipt = await tx.wait();
      
      // Extract proposal ID from event
      const proposalCreatedEvent = receipt.logs.find(
        log => log.fragment?.name === 'ProposalCreated'
      );

      const proposalId = proposalCreatedEvent?.args?.proposalId?.toString() || 
                         ethers.keccak256(ethers.toUtf8Bytes(fullDescription));

      logger.info('Proposal created successfully', { 
        proposalId, 
        txHash: receipt.hash 
      });

      return {
        success: true,
        proposalId,
        txHash: receipt.hash,
        title,
        description: fullDescription,
        category,
        status: 'Pending',
      };
    } catch (error) {
      logger.error('Failed to create proposal', { error: error.message });
      throw error;
    }
  }

  /**
   * Cast a vote on a proposal
   * @param {string} proposalId - Proposal ID
   * @param {Object} voteData - Vote details
   */
  async castVote(proposalId, voteData) {
    await this.initialize();

    if (!this.governor) {
      throw new Error('Governor contract not configured');
    }

    const { support, reason = '', voterId } = voteData;

    try {
      // Convert support to number
      let voteType;
      if (typeof support === 'string') {
        voteType = support.toLowerCase() === 'for' ? VoteType.For :
                   support.toLowerCase() === 'against' ? VoteType.Against :
                   VoteType.Abstain;
      } else {
        voteType = support;
      }

      logger.info('Casting vote', { proposalId, support: voteType, voterId });

      let tx;
      if (reason) {
        tx = await this.governor.castVoteWithReason(proposalId, voteType, reason);
      } else {
        tx = await this.governor.castVote(proposalId, voteType);
      }

      const receipt = await tx.wait();

      logger.info('Vote cast successfully', { 
        proposalId, 
        txHash: receipt.hash,
        support: voteType 
      });

      return {
        success: true,
        proposalId,
        txHash: receipt.hash,
        support: voteType,
        reason,
      };
    } catch (error) {
      logger.error('Failed to cast vote', { error: error.message, proposalId });
      throw error;
    }
  }

  /**
   * Get proposal details
   * @param {string} proposalId - Proposal ID
   */
  async getProposal(proposalId) {
    await this.initialize();

    if (!this.governor) {
      throw new Error('Governor contract not configured');
    }

    try {
      const [state, snapshot, deadline, votes] = await Promise.all([
        this.governor.state(proposalId),
        this.governor.proposalSnapshot(proposalId),
        this.governor.proposalDeadline(proposalId),
        this.governor.proposalVotes(proposalId),
      ]);

      return {
        proposalId,
        state: ProposalState[state] || 'Unknown',
        stateCode: Number(state),
        snapshot: snapshot.toString(),
        deadline: deadline.toString(),
        votes: {
          against: votes.againstVotes.toString(),
          for: votes.forVotes.toString(),
          abstain: votes.abstainVotes.toString(),
        },
      };
    } catch (error) {
      logger.error('Failed to get proposal', { error: error.message, proposalId });
      throw error;
    }
  }

  /**
   * Get governance parameters
   */
  async getGovernanceParams() {
    await this.initialize();

    if (!this.governor) {
      return {
        configured: false,
        message: 'Governor contract not configured',
      };
    }

    try {
      const [name, votingDelay, votingPeriod, proposalThreshold] = await Promise.all([
        this.governor.name(),
        this.governor.votingDelay(),
        this.governor.votingPeriod(),
        this.governor.proposalThreshold(),
      ]);

      const currentBlock = await this.provider.getBlockNumber();
      const quorum = await this.governor.quorum(currentBlock - 1);

      return {
        configured: true,
        name,
        votingDelay: votingDelay.toString(),
        votingPeriod: votingPeriod.toString(),
        proposalThreshold: proposalThreshold.toString(),
        quorum: quorum.toString(),
        currentBlock,
      };
    } catch (error) {
      logger.error('Failed to get governance params', { error: error.message });
      throw error;
    }
  }

  /**
   * Execute a passed proposal
   * @param {string} proposalId - Proposal ID
   * @param {Object} proposalData - Original proposal data for hash
   */
  async executeProposal(proposalId, proposalData) {
    await this.initialize();

    if (!this.governor) {
      throw new Error('Governor contract not configured');
    }

    const { targets, values, calldatas, description } = proposalData;

    try {
      const descriptionHash = ethers.keccak256(ethers.toUtf8Bytes(description));

      logger.info('Executing proposal', { proposalId });

      const tx = await this.governor.execute(
        targets,
        values,
        calldatas,
        descriptionHash
      );

      const receipt = await tx.wait();

      logger.info('Proposal executed successfully', { 
        proposalId, 
        txHash: receipt.hash 
      });

      return {
        success: true,
        proposalId,
        txHash: receipt.hash,
        status: 'Executed',
      };
    } catch (error) {
      logger.error('Failed to execute proposal', { error: error.message, proposalId });
      throw error;
    }
  }

  /**
   * Check if an address has voted on a proposal
   * @param {string} proposalId - Proposal ID
   * @param {string} address - Voter address
   */
  async hasVoted(proposalId, address) {
    await this.initialize();

    if (!this.governor) {
      throw new Error('Governor contract not configured');
    }

    try {
      const voted = await this.governor.hasVoted(proposalId, address);
      return { proposalId, address, hasVoted: voted };
    } catch (error) {
      logger.error('Failed to check vote status', { error: error.message });
      throw error;
    }
  }

  /**
   * Get voting power for an address
   * @param {string} address - Voter address
   * @param {number} blockNumber - Block number (optional, uses current - 1)
   */
  async getVotingPower(address, blockNumber = null) {
    await this.initialize();

    if (!this.governor) {
      throw new Error('Governor contract not configured');
    }

    try {
      const block = blockNumber || (await this.provider.getBlockNumber()) - 1;
      const votes = await this.governor.getVotes(address, block);
      return {
        address,
        blockNumber: block,
        votingPower: votes.toString(),
      };
    } catch (error) {
      logger.error('Failed to get voting power', { error: error.message, address });
      throw error;
    }
  }
}

// Export singleton instance
module.exports = new GovernanceService();
