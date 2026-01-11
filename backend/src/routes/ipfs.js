/**
 * GramPulse IPFS Upload Routes
 * 
 * Endpoints for uploading proof files to IPFS
 */

const express = require('express');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const ipfsService = require('../services/ipfsService');
const { authenticateApiKey, validateRequest } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Configure multer for file uploads (memory storage)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
    files: 5, // Max 5 files
  },
  fileFilter: (req, file, cb) => {
    // Allow images and videos
    const allowedMimes = [
      'image/jpeg',
      'image/png',
      'image/webp',
      'video/mp4',
      'video/webm',
    ];
    
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`File type ${file.mimetype} not allowed`), false);
    }
  },
});

/**
 * POST /ipfs/upload
 * 
 * Upload a single file to IPFS
 * 
 * Body (multipart/form-data):
 * - file: The file to upload
 * - grievanceId: Associated grievance ID
 * 
 * Response:
 * - cid: IPFS CID
 * - gatewayUrl: URL to access the file
 */
router.post(
  '/upload',
  authenticateApiKey,
  upload.single('file'),
  async (req, res, next) => {
    const requestId = uuidv4();

    if (!req.file) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'No file provided',
        requestId,
      });
    }

    const { grievanceId } = req.body;

    logger.info('IPFS upload request', {
      requestId,
      fileName: req.file.originalname,
      size: req.file.size,
      mimeType: req.file.mimetype,
      grievanceId,
    });

    try {
      if (!ipfsService.isReady()) {
        return res.status(503).json({
          error: 'Service Unavailable',
          message: 'IPFS service is not configured',
          requestId,
        });
      }

      const result = await ipfsService.uploadFile(
        req.file.buffer,
        req.file.originalname,
        { grievanceId: grievanceId || 'unknown' }
      );

      res.status(201).json({
        success: true,
        requestId,
        data: {
          cid: result.cid,
          gatewayUrl: result.gatewayUrl,
          size: result.size,
          fileName: req.file.originalname,
          mimeType: req.file.mimetype,
        },
      });

    } catch (error) {
      logger.error('IPFS upload failed', {
        requestId,
        error: error.message,
      });
      next(error);
    }
  }
);

/**
 * POST /ipfs/proof-package
 * 
 * Create a complete proof-of-resolution package
 * 
 * Body (multipart/form-data):
 * - files: Array of proof files (images/videos)
 * - grievanceId (required): Grievance document ID
 * - villageId (required): Village identifier
 * - resolverRole (required): Role of resolver
 * - resolverId (required): User ID of resolver
 * - description: Resolution description
 * 
 * Response:
 * - packageCid: IPFS CID of the metadata package
 * - packageUrl: Gateway URL for the package
 * - mediaFiles: Array of uploaded media with CIDs
 */
router.post(
  '/proof-package',
  authenticateApiKey,
  upload.array('files', 5),
  async (req, res, next) => {
    const requestId = uuidv4();
    const { grievanceId, villageId, resolverRole, resolverId, description } = req.body;

    // Validate required fields
    if (!grievanceId || !villageId || !resolverRole || !resolverId) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Missing required fields: grievanceId, villageId, resolverRole, resolverId',
        requestId,
      });
    }

    logger.info('Proof package request', {
      requestId,
      grievanceId,
      villageId,
      fileCount: req.files?.length || 0,
    });

    try {
      if (!ipfsService.isReady()) {
        return res.status(503).json({
          error: 'Service Unavailable',
          message: 'IPFS service is not configured',
          requestId,
        });
      }

      // Prepare media files
      const mediaFiles = (req.files || []).map(file => ({
        buffer: file.buffer,
        fileName: file.originalname,
        mimeType: file.mimetype,
      }));

      const result = await ipfsService.createProofPackage({
        grievanceId,
        villageId,
        resolverRole,
        resolverId,
        description: description || '',
        mediaFiles,
      });

      res.status(201).json({
        success: true,
        requestId,
        data: {
          packageCid: result.packageCid,
          packageUrl: result.packageUrl,
          mediaFiles: result.mediaFiles,
          timestamp: result.metadata.resolution.timestamp,
        },
      });

    } catch (error) {
      logger.error('Proof package creation failed', {
        requestId,
        grievanceId,
        error: error.message,
      });
      next(error);
    }
  }
);

/**
 * GET /ipfs/:cid
 * 
 * Get IPFS content (proxied through our gateway)
 * 
 * This is useful for:
 * - Avoiding CORS issues
 * - Caching
 * - Rate limiting
 */
router.get('/:cid', async (req, res, next) => {
  const { cid } = req.params;

  // Validate CID format (basic check)
  if (!cid || cid.length < 10) {
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Invalid CID format',
    });
  }

  try {
    // Redirect to gateway URL
    const gatewayUrl = ipfsService.getGatewayUrl(cid);
    res.redirect(302, gatewayUrl);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /ipfs/health
 * 
 * Health check for IPFS service
 */
router.get('/health', async (req, res) => {
  res.json({
    status: ipfsService.isReady() ? 'healthy' : 'not configured',
    provider: process.env.IPFS_PROVIDER || 'pinata',
    configured: !!process.env.IPFS_API_KEY,
  });
});

module.exports = router;
