/**
 * GramPulse Attestation Service - Main Entry Point
 * 
 * Express server for blockchain attestation operations
 * 
 * Features:
 * - EAS (Ethereum Attestation Service) integration
 * - Resolution attestations for grievances
 * - Public verification endpoints
 * - Rate limiting and security headers
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { config, validateConfig } = require('./config');
const easService = require('./services/easService');
const ipfsService = require('./services/ipfsService');
const attestRoutes = require('./routes/attest');
const verifyRoutes = require('./routes/verify');
const ipfsRoutes = require('./routes/ipfs');
const { 
  logRequest, 
  errorHandler, 
  notFoundHandler,
  addRateLimitHeaders 
} = require('./middleware/auth');
const logger = require('./utils/logger');

// Validate configuration before starting
validateConfig();

const app = express();

// ===========================================
// Security Middleware
// ===========================================

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
}));

// CORS configuration
const corsOptions = {
  origin: config.allowedOrigins,
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'x-api-key'],
  maxAge: 86400, // 24 hours
};
app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: config.rateLimitRpm,
  message: {
    error: 'Too Many Requests',
    message: 'Rate limit exceeded. Please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// ===========================================
// Request Parsing & Logging
// ===========================================

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

// HTTP request logging
if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Custom request logging
app.use(logRequest);
app.use(addRateLimitHeaders);

// ===========================================
// Health Check
// ===========================================

app.get('/health', async (req, res) => {
  try {
    const status = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'grampulse-attestation',
      version: '1.0.0',
      network: config.network,
      easInitialized: easService.initialized,
    };

    if (easService.initialized) {
      status.attesterAddress = easService.getAttesterAddress();
      status.schemaUid = easService.getResolutionSchemaUid();
    }

    res.json(status);
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
    });
  }
});

// ===========================================
// API Routes
// ===========================================

// Attestation routes (require API key)
app.use('/attest', attestRoutes);

// IPFS routes (require API key for uploads)
app.use('/ipfs', ipfsRoutes);

// Verification routes (public)
app.use('/verify', verifyRoutes);

// API info endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'GramPulse Attestation Service',
    version: '1.0.0',
    description: 'Blockchain attestation service for verifiable civic actions',
    endpoints: {
      health: 'GET /health',
      attest: {
        resolution: 'POST /attest/resolution (requires API key)',
        reputation: 'POST /attest/reputation (coming soon)',
        vsi: 'POST /attest/vsi (coming soon)',
      },
      verify: {
        byUid: 'GET /verify/:uid (public)',
        health: 'GET /verify/health (public)',
      },
    },
    documentation: 'https://github.com/naveen-astra/grampulse-icsrf',
  });
});

// ===========================================
// Error Handling
// ===========================================

app.use(notFoundHandler);
app.use(errorHandler);

// ===========================================
// Server Startup
// ===========================================

const startServer = async () => {
  try {
    // Initialize EAS service
    logger.info('Initializing EAS Service...');
    await easService.initialize();

    // Initialize IPFS service (optional)
    logger.info('Initializing IPFS Service...');
    try {
      await ipfsService.initialize();
    } catch (ipfsError) {
      logger.warn('IPFS Service not available:', ipfsError.message);
    }

    // Start the server
    const server = app.listen(config.port, () => {
      logger.info(`
╔══════════════════════════════════════════════════════════════╗
║           GramPulse Attestation Service Started              ║
╠══════════════════════════════════════════════════════════════╣
║  Port:     ${String(config.port).padEnd(48)}║
║  Network:  ${config.network.padEnd(48)}║
║  Mode:     ${config.nodeEnv.padEnd(48)}║
║  IPFS:     ${(ipfsService.isReady() ? 'Enabled' : 'Disabled').padEnd(48)}║
╚══════════════════════════════════════════════════════════════╝
      `);
      logger.info('Ready to receive attestation requests');
    });

    // Graceful shutdown
    const gracefulShutdown = (signal) => {
      logger.info(`${signal} received. Starting graceful shutdown...`);
      server.close(() => {
        logger.info('Server closed');
        process.exit(0);
      });

      // Force close after 10 seconds
      setTimeout(() => {
        logger.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

module.exports = app; // For testing
