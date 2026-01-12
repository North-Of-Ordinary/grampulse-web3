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
const governanceService = require('./services/governanceService');
const reputationService = require('./services/reputationService');
const dashboardService = require('./services/dashboardService');
const batchAttestationService = require('./services/batchAttestationService');
const attestRoutes = require('./routes/attest');
const verifyRoutes = require('./routes/verify');
const ipfsRoutes = require('./routes/ipfs');
const governanceRoutes = require('./routes/governance');
const reputationRoutes = require('./routes/reputation');
const dashboardRoutes = require('./routes/dashboard');
const batchRoutes = require('./routes/batch');
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

// Governance routes (DAO)
app.use('/governance', governanceRoutes);

// Reputation routes
app.use('/reputation', reputationRoutes);

// Dashboard routes (public transparency)
app.use('/dashboard', dashboardRoutes);

// Batch attestation routes
app.use('/batch', batchRoutes);

// API info endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'GramPulse Attestation Service',
    version: '2.0.0',
    description: 'Blockchain attestation service for verifiable civic actions with DAO governance',
    endpoints: {
      health: 'GET /health',
      attest: {
        resolution: 'POST /attest/resolution (requires API key)',
      },
      verify: {
        byUid: 'GET /verify/:uid (public)',
        health: 'GET /verify/health (public)',
      },
      ipfs: {
        upload: 'POST /ipfs/upload (requires API key)',
        proofPackage: 'POST /ipfs/proof-package (requires API key)',
      },
      governance: {
        createProposal: 'POST /governance/proposal (requires API key)',
        vote: 'POST /governance/vote (requires API key)',
        getProposal: 'GET /governance/proposal/:id (public)',
        params: 'GET /governance/params (public)',
      },
      reputation: {
        addPoints: 'POST /reputation/points (requires API key)',
        getScore: 'GET /reputation/score/:address (public)',
        awardBadge: 'POST /reputation/badge (requires API key)',
        getBadges: 'GET /reputation/badges/:address (public)',
        leaderboard: 'GET /reputation/leaderboard (public)',
      },
      dashboard: {
        overview: 'GET /dashboard/overview (public)',
        categories: 'GET /dashboard/categories (public)',
        panchayats: 'GET /dashboard/panchayats (public)',
        trend: 'GET /dashboard/trend (public)',
        stats: 'GET /dashboard/stats (public)',
      },
      batch: {
        attest: 'POST /batch/attest (requires API key)',
        revoke: 'POST /batch/revoke (requires API key)',
        fullWorkflow: 'POST /batch/full-workflow (requires API key)',
        schema: 'GET /batch/schema (public)',
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

    // Initialize Governance service (optional - requires Governor contract)
    logger.info('Initializing Governance Service...');
    try {
      await governanceService.initialize();
    } catch (govError) {
      logger.warn('Governance Service not available:', govError.message);
    }

    // Initialize Reputation service
    logger.info('Initializing Reputation Service...');
    try {
      await reputationService.initialize();
    } catch (repError) {
      logger.warn('Reputation Service not available:', repError.message);
    }

    // Initialize Dashboard service
    logger.info('Initializing Dashboard Service...');
    try {
      await dashboardService.initialize();
    } catch (dashError) {
      logger.warn('Dashboard Service not available:', dashError.message);
    }

    // Initialize Batch Attestation service
    logger.info('Initializing Batch Attestation Service...');
    try {
      await batchAttestationService.initialize();
    } catch (batchError) {
      logger.warn('Batch Attestation Service not available:', batchError.message);
    }

    // Start the server - bind to 0.0.0.0 to allow connections from other devices
    const server = app.listen(config.port, '0.0.0.0', () => {
      logger.info(`
╔══════════════════════════════════════════════════════════════╗
║        GramPulse Attestation Service v2.0 Started            ║
╠══════════════════════════════════════════════════════════════╣
║  Port:       ${String(config.port).padEnd(46)}║
║  Host:       ${'0.0.0.0 (all interfaces)'.padEnd(46)}║
║  Network:    ${config.network.padEnd(46)}║
║  Mode:       ${config.nodeEnv.padEnd(46)}║
║  IPFS:       ${(ipfsService.isReady() ? 'Enabled' : 'Disabled').padEnd(46)}║
║  Governance: ${(governanceService.initialized ? 'Enabled' : 'Disabled').padEnd(46)}║
║  Reputation: ${(reputationService.initialized ? 'Enabled' : 'Disabled').padEnd(46)}║
║  Dashboard:  ${(dashboardService.initialized ? 'Enabled' : 'Disabled').padEnd(46)}║
╚══════════════════════════════════════════════════════════════╝
      `);
      logger.info('Ready to receive requests');
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
