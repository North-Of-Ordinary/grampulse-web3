/// Network configuration for blockchain interactions.
/// 
/// GramPulse uses Optimism (OP Stack) for on-chain attestations.
/// This file defines network parameters for different environments.
library;

/// Supported blockchain networks for GramPulse
enum Web3Network {
  /// Optimism Mainnet - Production (Canonical Trust Layer)
  optimismMainnet,
  
  /// Optimism Sepolia Testnet - Development/Testing
  optimismSepolia,
  
  /// Shardeum Sphinx Testnet - Scalable Event Layer (Optional)
  shardeumSphinx,
  
  /// Local development network
  localhost,
}

/// Configuration for a specific blockchain network
class NetworkConfig {
  /// Human-readable network name
  final String name;
  
  /// Chain ID for the network
  final int chainId;
  
  /// RPC URL for connecting to the network
  final String rpcUrl;
  
  /// Block explorer URL for viewing transactions
  final String explorerUrl;
  
  /// EAS (Ethereum Attestation Service) contract address
  final String easContractAddress;
  
  /// EAS Schema Registry contract address
  final String easSchemaRegistryAddress;
  
  /// Whether this is a testnet
  final bool isTestnet;
  
  /// Native currency symbol
  final String currencySymbol;
  
  const NetworkConfig({
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.easContractAddress,
    required this.easSchemaRegistryAddress,
    required this.isTestnet,
    this.currencySymbol = 'ETH',
  });
  
  /// Get configuration for a specific network
  static NetworkConfig forNetwork(Web3Network network) {
    switch (network) {
      case Web3Network.optimismMainnet:
        return _optimismMainnet;
      case Web3Network.optimismSepolia:
        return _optimismSepolia;
      case Web3Network.shardeumSphinx:
        return _shardeumSphinx;
      case Web3Network.localhost:
        return _localhost;
    }
  }
  
  /// Optimism Mainnet configuration
  static const NetworkConfig _optimismMainnet = NetworkConfig(
    name: 'Optimism Mainnet',
    chainId: 10,
    rpcUrl: 'https://mainnet.optimism.io',
    explorerUrl: 'https://optimistic.etherscan.io',
    // EAS contract addresses on Optimism Mainnet
    easContractAddress: '0x4200000000000000000000000000000000000021',
    easSchemaRegistryAddress: '0x4200000000000000000000000000000000000020',
    isTestnet: false,
    currencySymbol: 'ETH',
  );
  
  /// Optimism Sepolia Testnet configuration
  static const NetworkConfig _optimismSepolia = NetworkConfig(
    name: 'Optimism Sepolia',
    chainId: 11155420,
    rpcUrl: 'https://sepolia.optimism.io',
    explorerUrl: 'https://sepolia-optimism.etherscan.io',
    // EAS contract addresses on Optimism Sepolia
    easContractAddress: '0x4200000000000000000000000000000000000021',
    easSchemaRegistryAddress: '0x4200000000000000000000000000000000000020',
    isTestnet: true,
    currencySymbol: 'ETH',
  );
  
  /// Shardeum Sphinx Testnet configuration
  /// Role: High-throughput civic event layer (scalability)
  /// NOTE: Shardeum is NOT for attestations - use Optimism for trust
  static const NetworkConfig _shardeumSphinx = NetworkConfig(
    name: 'Shardeum Sphinx',
    chainId: 8082,
    rpcUrl: 'https://atomium.shardeum.org',
    explorerUrl: 'https://explorer-atomium.shardeum.org',
    // Shardeum doesn't use EAS - these are placeholders
    easContractAddress: '0x0000000000000000000000000000000000000000',
    easSchemaRegistryAddress: '0x0000000000000000000000000000000000000000',
    isTestnet: true,
    currencySymbol: 'SHM',
  );
  
  /// Local development network configuration
  static const NetworkConfig _localhost = NetworkConfig(
    name: 'Localhost',
    chainId: 31337,
    rpcUrl: 'http://127.0.0.1:8545',
    explorerUrl: '',
    easContractAddress: '0x0000000000000000000000000000000000000000',
    easSchemaRegistryAddress: '0x0000000000000000000000000000000000000000',
    isTestnet: true,
    currencySymbol: 'ETH',
  );
  
  @override
  String toString() => 'NetworkConfig($name, chainId: $chainId)';
}

/// GramPulse-specific EAS schema definitions
class GramPulseSchemas {
  GramPulseSchemas._();
  
  /// Schema for Grievance Resolution attestations
  /// 
  /// Fields:
  /// - grievanceId: string (Firebase document ID)
  /// - villageId: string (Village identifier)
  /// - resolverRole: string (officer/volunteer)
  /// - ipfsHash: string (IPFS CID of proof)
  /// - resolutionTimestamp: uint256 (Unix timestamp)
  static const String resolutionSchema = 
      'string grievanceId,string villageId,string resolverRole,string ipfsHash,uint256 resolutionTimestamp';
  
  /// Schema UID for Resolution attestations (set after deployment)
  /// This will be populated from environment config
  static String? resolutionSchemaUid;
  
  /// Schema for Civic Reputation attestations
  static const String reputationSchema = 
      'address entity,uint256 score,uint256 resolvedCount,uint256 avgResolutionTime';
  
  /// Schema for Village Sustainability Index (VSI) anchoring
  static const String vsiSchema = 
      'string villageId,uint256 waterScore,uint256 roadScore,uint256 powerScore,uint256 overallScore,uint256 timestamp';
}
