/**
 * GramPulse Attestation Service - Configuration
 * 
 * Loads and validates environment configuration.
 */

require('dotenv').config();

const config = {
  // Server
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  isDev: process.env.NODE_ENV !== 'production',

  // Blockchain
  network: process.env.NETWORK || 'optimism-sepolia',
  rpcUrl: process.env.RPC_URL || 'https://sepolia.optimism.io',
  attesterPrivateKey: process.env.ATTESTER_PRIVATE_KEY,

  // EAS
  easContractAddress: process.env.EAS_CONTRACT_ADDRESS || '0x4200000000000000000000000000000000000021',
  schemaRegistryAddress: process.env.SCHEMA_REGISTRY_ADDRESS || '0x4200000000000000000000000000000000000020',
  resolutionSchemaUid: process.env.RESOLUTION_SCHEMA_UID || null,

  // Security
  apiKey: process.env.API_KEY,
  allowedOrigins: (process.env.ALLOWED_ORIGINS || 'http://localhost:3000').split(','),
  rateLimitRpm: parseInt(process.env.RATE_LIMIT_RPM || '60', 10),

  // Logging
  logLevel: process.env.LOG_LEVEL || 'debug',

  // Network configurations
  networks: {
    'optimism-mainnet': {
      chainId: 10,
      name: 'Optimism Mainnet',
      rpcUrl: 'https://mainnet.optimism.io',
      explorerUrl: 'https://optimistic.etherscan.io',
    },
    'optimism-sepolia': {
      chainId: 11155420,
      name: 'Optimism Sepolia',
      rpcUrl: 'https://sepolia.optimism.io',
      explorerUrl: 'https://sepolia-optimism.etherscan.io',
    },
  },
};

// Validation
function validateConfig() {
  const errors = [];

  if (!config.attesterPrivateKey) {
    errors.push('ATTESTER_PRIVATE_KEY is required');
  }

  if (!config.apiKey && config.nodeEnv === 'production') {
    errors.push('API_KEY is required in production');
  }

  if (!config.networks[config.network]) {
    errors.push(`Invalid NETWORK: ${config.network}`);
  }

  return errors;
}

// Get current network config
function getNetworkConfig() {
  return config.networks[config.network];
}

module.exports = {
  config,
  validateConfig,
  getNetworkConfig,
};
