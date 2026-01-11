/**
 * GramPulse IPFS Service
 * 
 * Handles IPFS uploads for proof-of-resolution files
 * Uses Pinata or Web3.Storage for pinning
 */

const axios = require('axios');
const FormData = require('form-data');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');

/**
 * IPFS Service Configuration
 */
const IPFS_CONFIG = {
  pinata: {
    apiUrl: 'https://api.pinata.cloud',
    gateway: 'https://gateway.pinata.cloud/ipfs',
  },
  web3Storage: {
    apiUrl: 'https://api.web3.storage',
    gateway: 'https://w3s.link/ipfs',
  },
};

class IPFSService {
  constructor() {
    this.provider = process.env.IPFS_PROVIDER || 'pinata';
    this.apiKey = process.env.IPFS_API_KEY;
    this.apiSecret = process.env.IPFS_API_SECRET;
    this.initialized = false;
  }

  /**
   * Initialize the IPFS service
   */
  async initialize() {
    if (!this.apiKey) {
      logger.warn('IPFS API key not configured. IPFS uploads will be disabled.');
      return;
    }

    try {
      // Test connection based on provider
      if (this.provider === 'pinata') {
        await this.testPinataConnection();
      }
      
      this.initialized = true;
      logger.info(`IPFS Service initialized with provider: ${this.provider}`);
    } catch (error) {
      logger.error('Failed to initialize IPFS Service:', error);
      throw error;
    }
  }

  /**
   * Test Pinata API connection
   */
  async testPinataConnection() {
    const response = await axios.get(
      `${IPFS_CONFIG.pinata.apiUrl}/data/testAuthentication`,
      {
        headers: {
          'pinata_api_key': this.apiKey,
          'pinata_secret_api_key': this.apiSecret,
        },
      }
    );
    
    if (response.status !== 200) {
      throw new Error('Pinata authentication failed');
    }
    
    logger.info('Pinata connection verified');
  }

  /**
   * Upload a file buffer to IPFS
   * 
   * @param {Buffer} fileBuffer - File content as buffer
   * @param {string} fileName - Original filename
   * @param {Object} metadata - Additional metadata
   * @returns {Object} - Upload result with CID and gateway URL
   */
  async uploadFile(fileBuffer, fileName, metadata = {}) {
    if (!this.initialized) {
      throw new Error('IPFS Service not initialized');
    }

    const uploadId = uuidv4();
    logger.info('Starting IPFS upload', { uploadId, fileName, size: fileBuffer.length });

    try {
      if (this.provider === 'pinata') {
        return await this.uploadToPinata(fileBuffer, fileName, metadata, uploadId);
      } else {
        throw new Error(`Unsupported IPFS provider: ${this.provider}`);
      }
    } catch (error) {
      logger.error('IPFS upload failed', { uploadId, error: error.message });
      throw error;
    }
  }

  /**
   * Upload to Pinata
   */
  async uploadToPinata(fileBuffer, fileName, metadata, uploadId) {
    const formData = new FormData();
    formData.append('file', fileBuffer, { filename: fileName });

    // Add metadata
    const pinataMetadata = JSON.stringify({
      name: `grampulse-proof-${uploadId}`,
      keyvalues: {
        app: 'grampulse',
        type: 'proof-of-resolution',
        uploadId,
        ...metadata,
      },
    });
    formData.append('pinataMetadata', pinataMetadata);

    // Pin options
    const pinataOptions = JSON.stringify({
      cidVersion: 1,
    });
    formData.append('pinataOptions', pinataOptions);

    const response = await axios.post(
      `${IPFS_CONFIG.pinata.apiUrl}/pinning/pinFileToIPFS`,
      formData,
      {
        maxBodyLength: Infinity,
        headers: {
          'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
          'pinata_api_key': this.apiKey,
          'pinata_secret_api_key': this.apiSecret,
        },
      }
    );

    const { IpfsHash, PinSize, Timestamp } = response.data;

    logger.info('IPFS upload successful', {
      uploadId,
      cid: IpfsHash,
      size: PinSize,
    });

    return {
      success: true,
      cid: IpfsHash,
      size: PinSize,
      timestamp: Timestamp,
      gatewayUrl: `${IPFS_CONFIG.pinata.gateway}/${IpfsHash}`,
      uploadId,
    };
  }

  /**
   * Upload JSON data to IPFS
   * 
   * @param {Object} data - JSON data to upload
   * @param {string} name - Name for the JSON file
   * @returns {Object} - Upload result with CID
   */
  async uploadJSON(data, name = 'data.json') {
    if (!this.initialized) {
      throw new Error('IPFS Service not initialized');
    }

    const uploadId = uuidv4();
    logger.info('Starting IPFS JSON upload', { uploadId, name });

    try {
      if (this.provider === 'pinata') {
        return await this.uploadJSONToPinata(data, name, uploadId);
      } else {
        throw new Error(`Unsupported IPFS provider: ${this.provider}`);
      }
    } catch (error) {
      logger.error('IPFS JSON upload failed', { uploadId, error: error.message });
      throw error;
    }
  }

  /**
   * Upload JSON to Pinata
   */
  async uploadJSONToPinata(data, name, uploadId) {
    const response = await axios.post(
      `${IPFS_CONFIG.pinata.apiUrl}/pinning/pinJSONToIPFS`,
      {
        pinataContent: data,
        pinataMetadata: {
          name: `grampulse-${name}-${uploadId}`,
          keyvalues: {
            app: 'grampulse',
            type: 'json-data',
            uploadId,
          },
        },
        pinataOptions: {
          cidVersion: 1,
        },
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'pinata_api_key': this.apiKey,
          'pinata_secret_api_key': this.apiSecret,
        },
      }
    );

    const { IpfsHash, PinSize, Timestamp } = response.data;

    logger.info('IPFS JSON upload successful', {
      uploadId,
      cid: IpfsHash,
    });

    return {
      success: true,
      cid: IpfsHash,
      size: PinSize,
      timestamp: Timestamp,
      gatewayUrl: `${IPFS_CONFIG.pinata.gateway}/${IpfsHash}`,
      uploadId,
    };
  }

  /**
   * Create a proof-of-resolution package
   * 
   * Bundles proof media with metadata into a single IPFS upload
   * 
   * @param {Object} params - Proof parameters
   * @param {string} params.grievanceId - Grievance document ID
   * @param {string} params.villageId - Village identifier
   * @param {string} params.resolverRole - Role of resolver
   * @param {string} params.resolverId - User ID of resolver
   * @param {string} params.description - Resolution description
   * @param {Array} params.mediaFiles - Array of {buffer, fileName, mimeType}
   * @returns {Object} - Package upload result
   */
  async createProofPackage(params) {
    const {
      grievanceId,
      villageId,
      resolverRole,
      resolverId,
      description,
      mediaFiles = [],
    } = params;

    const uploadId = uuidv4();
    logger.info('Creating proof package', { uploadId, grievanceId, mediaCount: mediaFiles.length });

    try {
      // Upload media files first
      const mediaUploads = [];
      for (const media of mediaFiles) {
        const result = await this.uploadFile(media.buffer, media.fileName, {
          grievanceId,
          mediaType: media.mimeType,
        });
        mediaUploads.push({
          cid: result.cid,
          fileName: media.fileName,
          mimeType: media.mimeType,
          size: result.size,
          gatewayUrl: result.gatewayUrl,
        });
      }

      // Create metadata JSON
      const proofMetadata = {
        version: '1.0.0',
        type: 'grampulse-proof-of-resolution',
        grievanceId,
        villageId,
        resolution: {
          resolverRole,
          resolverId,
          description,
          timestamp: new Date().toISOString(),
          unixTimestamp: Math.floor(Date.now() / 1000),
        },
        media: mediaUploads,
        packageId: uploadId,
      };

      // Upload metadata JSON
      const metadataResult = await this.uploadJSON(
        proofMetadata,
        `proof-${grievanceId}`
      );

      logger.info('Proof package created', {
        uploadId,
        grievanceId,
        packageCid: metadataResult.cid,
        mediaCount: mediaUploads.length,
      });

      return {
        success: true,
        packageCid: metadataResult.cid,
        packageUrl: metadataResult.gatewayUrl,
        metadata: proofMetadata,
        mediaFiles: mediaUploads,
        uploadId,
      };

    } catch (error) {
      logger.error('Failed to create proof package', {
        uploadId,
        grievanceId,
        error: error.message,
      });
      throw error;
    }
  }

  /**
   * Get content from IPFS
   * 
   * @param {string} cid - IPFS CID
   * @returns {Object} - Content data
   */
  async getContent(cid) {
    const gateway = this.provider === 'pinata' 
      ? IPFS_CONFIG.pinata.gateway 
      : IPFS_CONFIG.web3Storage.gateway;

    try {
      const response = await axios.get(`${gateway}/${cid}`, {
        timeout: 30000,
      });
      return response.data;
    } catch (error) {
      logger.error('Failed to fetch IPFS content', { cid, error: error.message });
      throw error;
    }
  }

  /**
   * Get gateway URL for a CID
   */
  getGatewayUrl(cid) {
    const gateway = this.provider === 'pinata' 
      ? IPFS_CONFIG.pinata.gateway 
      : IPFS_CONFIG.web3Storage.gateway;
    return `${gateway}/${cid}`;
  }

  /**
   * Check if service is ready
   */
  isReady() {
    return this.initialized;
  }
}

// Singleton instance
const ipfsService = new IPFSService();

module.exports = ipfsService;
