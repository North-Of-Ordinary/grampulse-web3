/**
 * GramPulse Attestation Service - EAS Service
 * 
 * Handles all Ethereum Attestation Service interactions:
 * - Schema registration
 * - Creating attestations
 * - Verifying attestations
 */

const { EAS, SchemaRegistry, SchemaEncoder } = require('@ethereum-attestation-service/eas-sdk');
const { ethers } = require('ethers');
const { config, getNetworkConfig } = require('../config');
const logger = require('../utils/logger');

/**
 * GramPulse Resolution Schema
 * 
 * Fields:
 * - grievanceId: Firebase document ID of the grievance
 * - villageId: Identifier of the village
 * - resolverRole: Role of the resolver (officer/volunteer)
 * - ipfsHash: IPFS CID of the proof (photo/video)
 * - resolutionTimestamp: Unix timestamp of resolution
 */
const RESOLUTION_SCHEMA = 'string grievanceId,string villageId,string resolverRole,string ipfsHash,uint256 resolutionTimestamp';

class EASService {
  constructor() {
    this.provider = null;
    this.signer = null;
    this.eas = null;
    this.schemaRegistry = null;
    this.resolutionSchemaUid = null;
    this.initialized = false;
  }

  /**
   * Initialize the EAS service
   */
  async initialize() {
    if (this.initialized) return;

    try {
      const networkConfig = getNetworkConfig();
      
      // Create provider and signer
      this.provider = new ethers.JsonRpcProvider(config.rpcUrl);
      this.signer = new ethers.Wallet(config.attesterPrivateKey, this.provider);

      // Verify network connection
      const network = await this.provider.getNetwork();
      if (Number(network.chainId) !== networkConfig.chainId) {
        throw new Error(`Chain ID mismatch. Expected ${networkConfig.chainId}, got ${network.chainId}`);
      }

      logger.info(`Connected to ${networkConfig.name} (Chain ID: ${network.chainId})`);
      logger.info(`Attester address: ${this.signer.address}`);

      // Check attester balance
      const balance = await this.provider.getBalance(this.signer.address);
      const balanceEth = ethers.formatEther(balance);
      logger.info(`Attester balance: ${balanceEth} ETH`);

      if (balance === 0n) {
        logger.warn('Attester wallet has no ETH! Attestations will fail.');
      }

      // Initialize EAS
      this.eas = new EAS(config.easContractAddress);
      this.eas.connect(this.signer);

      // Initialize Schema Registry
      this.schemaRegistry = new SchemaRegistry(config.schemaRegistryAddress);
      this.schemaRegistry.connect(this.signer);

      // Get or register resolution schema
      await this.ensureResolutionSchema();

      this.initialized = true;
      logger.info('EAS Service initialized successfully');

    } catch (error) {
      logger.error('Failed to initialize EAS Service:', error);
      throw error;
    }
  }

  /**
   * Ensure the resolution schema exists, register if not
   */
  async ensureResolutionSchema() {
    // If schema UID is provided in config, use it
    if (config.resolutionSchemaUid) {
      this.resolutionSchemaUid = config.resolutionSchemaUid;
      logger.info(`Using existing resolution schema: ${this.resolutionSchemaUid}`);
      return;
    }

    // Otherwise, register a new schema
    logger.info('Registering new resolution schema...');
    
    try {
      const tx = await this.schemaRegistry.register({
        schema: RESOLUTION_SCHEMA,
        resolverAddress: ethers.ZeroAddress, // No resolver
        revocable: true, // Attestations can be revoked
      });

      const receipt = await tx.wait();
      this.resolutionSchemaUid = receipt;
      
      logger.info(`Resolution schema registered: ${this.resolutionSchemaUid}`);
      logger.info('Add this to your .env file: RESOLUTION_SCHEMA_UID=' + this.resolutionSchemaUid);

    } catch (error) {
      // Schema might already exist, try to find it
      logger.warn('Could not register schema, it may already exist:', error.message);
      throw new Error('Resolution schema UID must be provided in RESOLUTION_SCHEMA_UID env var');
    }
  }

  /**
   * Create a resolution attestation
   * 
   * @param {Object} data - Attestation data
   * @param {string} data.grievanceId - Firebase grievance document ID
   * @param {string} data.villageId - Village identifier
   * @param {string} data.resolverRole - Role (officer/volunteer)
   * @param {string} data.ipfsHash - IPFS CID of proof
   * @returns {Object} - Attestation result with UID and transaction hash
   */
  async createResolutionAttestation(data) {
    if (!this.initialized) {
      throw new Error('EAS Service not initialized');
    }

    const { grievanceId, villageId, resolverRole, ipfsHash } = data;

    // Validate inputs
    if (!grievanceId || !villageId || !resolverRole) {
      throw new Error('Missing required fields: grievanceId, villageId, resolverRole');
    }

    const resolutionTimestamp = Math.floor(Date.now() / 1000);

    logger.info('Creating resolution attestation:', {
      grievanceId,
      villageId,
      resolverRole,
      ipfsHash: ipfsHash || 'none',
      timestamp: resolutionTimestamp,
    });

    try {
      // Encode the attestation data
      const schemaEncoder = new SchemaEncoder(RESOLUTION_SCHEMA);
      const encodedData = schemaEncoder.encodeData([
        { name: 'grievanceId', value: grievanceId, type: 'string' },
        { name: 'villageId', value: villageId, type: 'string' },
        { name: 'resolverRole', value: resolverRole, type: 'string' },
        { name: 'ipfsHash', value: ipfsHash || '', type: 'string' },
        { name: 'resolutionTimestamp', value: BigInt(resolutionTimestamp), type: 'uint256' },
      ]);

      // Create the attestation
      const tx = await this.eas.attest({
        schema: this.resolutionSchemaUid,
        data: {
          recipient: ethers.ZeroAddress, // No specific recipient
          expirationTime: 0n, // No expiration
          revocable: true,
          data: encodedData,
        },
      });

      // Wait for transaction confirmation
      const attestationUid = await tx.wait();

      logger.info('Attestation created:', {
        uid: attestationUid,
        grievanceId,
      });

      return {
        success: true,
        attestationUid,
        transactionHash: tx.tx.hash,
        timestamp: resolutionTimestamp,
        explorerUrl: `${getNetworkConfig().explorerUrl}/tx/${tx.tx.hash}`,
      };

    } catch (error) {
      logger.error('Failed to create attestation:', error);
      throw error;
    }
  }

  /**
   * Verify an attestation exists and is valid
   * 
   * @param {string} attestationUid - The attestation UID to verify
   * @returns {Object} - Verification result
   */
  async verifyAttestation(attestationUid) {
    if (!this.initialized) {
      throw new Error('EAS Service not initialized');
    }

    try {
      const attestation = await this.eas.getAttestation(attestationUid);

      if (!attestation || attestation.uid === ethers.ZeroHash) {
        return {
          valid: false,
          error: 'Attestation not found',
        };
      }

      // Check if revoked
      if (attestation.revocationTime !== 0n) {
        return {
          valid: false,
          error: 'Attestation has been revoked',
          revokedAt: Number(attestation.revocationTime),
        };
      }

      // Decode the data
      const schemaEncoder = new SchemaEncoder(RESOLUTION_SCHEMA);
      const decodedData = schemaEncoder.decodeData(attestation.data);

      return {
        valid: true,
        attestation: {
          uid: attestation.uid,
          schema: attestation.schema,
          attester: attestation.attester,
          timestamp: Number(attestation.time),
          data: {
            grievanceId: decodedData[0].value.value,
            villageId: decodedData[1].value.value,
            resolverRole: decodedData[2].value.value,
            ipfsHash: decodedData[3].value.value,
            resolutionTimestamp: Number(decodedData[4].value.value),
          },
        },
      };

    } catch (error) {
      logger.error('Failed to verify attestation:', error);
      return {
        valid: false,
        error: error.message,
      };
    }
  }

  /**
   * Revoke an attestation (admin function)
   * 
   * @param {string} attestationUid - The attestation UID to revoke
   * @returns {Object} - Revocation result
   */
  async revokeAttestation(attestationUid) {
    if (!this.initialized) {
      throw new Error('EAS Service not initialized');
    }

    try {
      const tx = await this.eas.revoke({
        schema: this.resolutionSchemaUid,
        data: {
          uid: attestationUid,
        },
      });

      await tx.wait();

      logger.info('Attestation revoked:', attestationUid);

      return {
        success: true,
        attestationUid,
        transactionHash: tx.tx.hash,
      };

    } catch (error) {
      logger.error('Failed to revoke attestation:', error);
      throw error;
    }
  }

  /**
   * Get the current schema UID
   */
  getResolutionSchemaUid() {
    return this.resolutionSchemaUid;
  }

  /**
   * Get attester wallet address
   */
  getAttesterAddress() {
    return this.signer?.address;
  }
}

// Singleton instance
const easService = new EASService();

module.exports = easService;
