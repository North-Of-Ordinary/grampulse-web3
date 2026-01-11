/**
 * GramPulse Attestation Middleware - API Key Authentication
 * 
 * Simple API key authentication for backend-to-backend calls
 * from the Flutter app (via Cloud Functions or direct)
 */

const { config } = require('../config');
const logger = require('../utils/logger');

/**
 * API Key Authentication Middleware
 * 
 * Expects header: x-api-key: <your-api-key>
 */
const authenticateApiKey = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];

  if (!apiKey) {
    logger.warn('Request missing API key', {
      ip: req.ip,
      path: req.path,
      method: req.method,
    });
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'API key is required',
    });
  }

  if (apiKey !== config.apiKey) {
    logger.warn('Invalid API key attempt', {
      ip: req.ip,
      path: req.path,
      method: req.method,
    });
    return res.status(403).json({
      error: 'Forbidden',
      message: 'Invalid API key',
    });
  }

  // API key is valid
  next();
};

/**
 * Request Validation Middleware
 * 
 * Validates that required fields are present in the request body
 */
const validateRequest = (requiredFields) => {
  return (req, res, next) => {
    const missingFields = requiredFields.filter(field => !req.body[field]);

    if (missingFields.length > 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: `Missing required fields: ${missingFields.join(', ')}`,
      });
    }

    next();
  };
};

/**
 * Rate Limiting Info Middleware
 * 
 * Adds rate limit headers to response
 */
const addRateLimitHeaders = (req, res, next) => {
  // This is informational; actual rate limiting is done by express-rate-limit
  res.setHeader('X-RateLimit-Policy', `${config.rateLimitRpm} requests per minute`);
  next();
};

/**
 * Request Logging Middleware
 * 
 * Logs incoming requests with relevant details
 */
const logRequest = (req, res, next) => {
  const startTime = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - startTime;
    logger.info('Request completed', {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
    });
  });

  next();
};

/**
 * Error Handler Middleware
 * 
 * Catches all errors and returns consistent JSON response
 */
const errorHandler = (err, req, res, next) => {
  logger.error('Unhandled error:', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  // Don't leak error details in production
  const isDev = config.nodeEnv === 'development';

  res.status(err.status || 500).json({
    error: err.name || 'Internal Server Error',
    message: isDev ? err.message : 'An unexpected error occurred',
    ...(isDev && { stack: err.stack }),
  });
};

/**
 * Not Found Handler
 */
const notFoundHandler = (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
  });
};

module.exports = {
  authenticateApiKey,
  validateRequest,
  addRateLimitHeaders,
  logRequest,
  errorHandler,
  notFoundHandler,
};
