/**
 * Batch Attestation Service - Advanced Attestation Operations
 * 
 * Handles:
 * - Batch attestation creation
 * - Attestation revocation
 * - Schema management
 * - Multi-attestation workflows
 */

const { EAS, SchemaEncoder, ZERO_BYTES32 } = require('@ethereum-attestation-service/eas-sdk');
const { ethers } = require('ethers');
const config = require('../config');
const logger = require('../utils/logger');

class BatchAttestationService {
  constructor() {
    this.provider = null;
    this.wallet = null;
    this.eas = null;
    this.schemaEncoder = null;
    this.initialized = false;
  }

  /**
   * Initialize the batch attestation service
   */
  async initialize() {
    if (this.initialized) {
      return;
    }

    try {
      this.provider = new ethers.JsonRpcProvider(config.blockchain.rpcUrl);
      this.wallet = new ethers.Wallet(config.blockchain.privateKey, this.provider);
      
      this.eas = new EAS(config.blockchain.easContract);
      this.eas.connect(this.wallet);

      // Resolution attestation schema
      this.schemaEncoder = new SchemaEncoder(
        'string issueId,string resolutionHash,uint64 timestamp,address resolver,string category,string panchayatId,string ipfsCid'
      );

      this.initialized = true;
      logger.info('Batch attestation service initialized');
    } catch (error) {
      logger.error('Failed to initialize batch attestation service', { error: error.message });
      throw error;
    }
  }

  /**
   * Create multiple attestations in a single transaction
   * @param {Array} attestations - Array of attestation data
   */
  async createBatchAttestations(attestations) {
    await this.initialize();

    if (!Array.isArray(attestations) || attestations.length === 0) {
      throw new Error('Attestations array is required and must not be empty');
    }

    if (attestations.length > 50) {
      throw new Error('Maximum 50 attestations per batch');
    }

    try {
      logger.info('Creating batch attestations', { count: attestations.length });

      const multiAttestData = attestations.map(att => ({
        schema: config.blockchain.schemaUid,
        data: [{
          recipient: att.recipient || ethers.ZeroAddress,
          expirationTime: att.expirationTime || 0n,
          revocable: att.revocable !== false,
          refUID: att.refUID || ZERO_BYTES32,
          data: this.schemaEncoder.encodeData([
            { name: 'issueId', value: att.issueId, type: 'string' },
            { name: 'resolutionHash', value: att.resolutionHash || '', type: 'string' },
            { name: 'timestamp', value: BigInt(att.timestamp || Date.now()), type: 'uint64' },
            { name: 'resolver', value: att.resolver || this.wallet.address, type: 'address' },
            { name: 'category', value: att.category || '', type: 'string' },
            { name: 'panchayatId', value: att.panchayatId || '', type: 'string' },
            { name: 'ipfsCid', value: att.ipfsCid || '', type: 'string' },
          ]),
          value: 0n,
        }],
      }));

      const tx = await this.eas.multiAttest(multiAttestData);
      const uids = await tx.wait();

      logger.info('Batch attestations created', { 
        count: uids.length,
        firstUid: uids[0],
        lastUid: uids[uids.length - 1],
      });

      return {
        success: true,
        count: uids.length,
        uids: uids.map(uid => uid.toString()),
        txHash: tx.tx?.hash,
      };
    } catch (error) {
      logger.error('Failed to create batch attestations', { error: error.message });
      throw error;
    }
  }

  /**
   * Revoke an attestation
   * @param {string} uid - Attestation UID to revoke
   * @param {Object} options - Revocation options
   */
  async revokeAttestation(uid, options = {}) {
    await this.initialize();

    const { reason = '', schemaUid = config.blockchain.schemaUid } = options;

    try {
      logger.info('Revoking attestation', { uid, reason });

      const tx = await this.eas.revoke({
        schema: schemaUid,
        data: {
          uid,
          value: 0n,
        },
      });

      const result = await tx.wait();

      logger.info('Attestation revoked', { uid, txHash: tx.tx?.hash });

      return {
        success: true,
        uid,
        revoked: true,
        reason,
        txHash: tx.tx?.hash,
        timestamp: Date.now(),
      };
    } catch (error) {
      logger.error('Failed to revoke attestation', { error: error.message, uid });
      throw error;
    }
  }

  /**
   * Revoke multiple attestations
   * @param {Array} uids - Array of UIDs to revoke
   * @param {Object} options - Revocation options
   */
  async batchRevokeAttestations(uids, options = {}) {
    await this.initialize();

    if (!Array.isArray(uids) || uids.length === 0) {
      throw new Error('UIDs array is required and must not be empty');
    }

    const { reason = '', schemaUid = config.blockchain.schemaUid } = options;

    try {
      logger.info('Batch revoking attestations', { count: uids.length });

      const multiRevokeData = [{
        schema: schemaUid,
        data: uids.map(uid => ({
          uid,
          value: 0n,
        })),
      }];

      const tx = await this.eas.multiRevoke(multiRevokeData);
      await tx.wait();

      logger.info('Batch attestations revoked', { count: uids.length });

      return {
        success: true,
        count: uids.length,
        uids,
        revoked: true,
        reason,
        txHash: tx.tx?.hash,
      };
    } catch (error) {
      logger.error('Failed to batch revoke attestations', { error: error.message });
      throw error;
    }
  }

  /**
   * Check if an attestation is revoked
   * @param {string} uid - Attestation UID
   */
  async isRevoked(uid) {
    await this.initialize();

    try {
      const attestation = await this.eas.getAttestation(uid);
      return {
        uid,
        revoked: attestation.revocationTime > 0n,
        revocationTime: attestation.revocationTime > 0n 
          ? new Date(Number(attestation.revocationTime) * 1000).toISOString() 
          : null,
      };
    } catch (error) {
      logger.error('Failed to check revocation status', { error: error.message, uid });
      throw error;
    }
  }

  /**
   * Create a referenced attestation (links to parent)
   * @param {Object} data - Attestation data
   * @param {string} parentUid - Parent attestation UID
   */
  async createReferencedAttestation(data, parentUid) {
    await this.initialize();

    try {
      logger.info('Creating referenced attestation', { parentUid });

      const encodedData = this.schemaEncoder.encodeData([
        { name: 'issueId', value: data.issueId, type: 'string' },
        { name: 'resolutionHash', value: data.resolutionHash || '', type: 'string' },
        { name: 'timestamp', value: BigInt(data.timestamp || Date.now()), type: 'uint64' },
        { name: 'resolver', value: data.resolver || this.wallet.address, type: 'address' },
        { name: 'category', value: data.category || '', type: 'string' },
        { name: 'panchayatId', value: data.panchayatId || '', type: 'string' },
        { name: 'ipfsCid', value: data.ipfsCid || '', type: 'string' },
      ]);

      const tx = await this.eas.attest({
        schema: config.blockchain.schemaUid,
        data: {
          recipient: data.recipient || ethers.ZeroAddress,
          expirationTime: 0n,
          revocable: true,
          refUID: parentUid, // Reference to parent
          data: encodedData,
          value: 0n,
        },
      });

      const uid = await tx.wait();

      logger.info('Referenced attestation created', { uid, parentUid });

      return {
        success: true,
        uid,
        parentUid,
        txHash: tx.tx?.hash,
      };
    } catch (error) {
      logger.error('Failed to create referenced attestation', { error: error.message });
      throw error;
    }
  }

  /**
   * Get attestation chain (parent and children)
   * @param {string} uid - Attestation UID
   */
  async getAttestationChain(uid) {
    await this.initialize();

    try {
      const attestation = await this.eas.getAttestation(uid);
      
      const chain = {
        current: {
          uid,
          refUID: attestation.refUID !== ZERO_BYTES32 ? attestation.refUID : null,
          timestamp: new Date(Number(attestation.time) * 1000).toISOString(),
          revoked: attestation.revocationTime > 0n,
        },
        parent: null,
        // Note: Finding children would require indexing or GraphQL query
      };

      // Get parent if exists
      if (attestation.refUID !== ZERO_BYTES32) {
        const parent = await this.eas.getAttestation(attestation.refUID);
        chain.parent = {
          uid: attestation.refUID,
          timestamp: new Date(Number(parent.time) * 1000).toISOString(),
          revoked: parent.revocationTime > 0n,
        };
      }

      return chain;
    } catch (error) {
      logger.error('Failed to get attestation chain', { error: error.message, uid });
      throw error;
    }
  }

  /**
   * Estimate gas for batch operation
   * @param {number} count - Number of attestations
   */
  async estimateBatchGas(count) {
    await this.initialize();

    try {
      // Approximate gas per attestation
      const baseGas = 50000n;
      const perAttestationGas = 150000n;
      const estimatedGas = baseGas + (perAttestationGas * BigInt(count));

      const feeData = await this.provider.getFeeData();
      const estimatedCost = estimatedGas * (feeData.gasPrice || 1000000000n);

      return {
        estimatedGas: estimatedGas.toString(),
        gasPrice: feeData.gasPrice?.toString(),
        estimatedCostWei: estimatedCost.toString(),
        estimatedCostEth: ethers.formatEther(estimatedCost),
        count,
      };
    } catch (error) {
      logger.error('Failed to estimate gas', { error: error.message });
      throw error;
    }
  }

  /**
   * Get schema details
   */
  async getSchemaDetails() {
    return {
      schemaUid: config.blockchain.schemaUid,
      schema: 'string issueId,string resolutionHash,uint64 timestamp,address resolver,string category,string panchayatId,string ipfsCid',
      fields: [
        { name: 'issueId', type: 'string', description: 'Unique issue identifier' },
        { name: 'resolutionHash', type: 'string', description: 'Hash of resolution details' },
        { name: 'timestamp', type: 'uint64', description: 'Resolution timestamp' },
        { name: 'resolver', type: 'address', description: 'Resolver wallet address' },
        { name: 'category', type: 'string', description: 'Issue category' },
        { name: 'panchayatId', type: 'string', description: 'Panchayat identifier' },
        { name: 'ipfsCid', type: 'string', description: 'IPFS CID for proof' },
      ],
      revocable: true,
      network: config.blockchain.network,
    };
  }
}

// Export singleton instance
module.exports = new BatchAttestationService();
