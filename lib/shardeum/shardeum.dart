// Shardeum Module - Scalable Civic Event Layer
// 
// Architecture Summary:
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 
// "Shardeum scales events, Optimism certifies outcomes"
// 
// SHARDEUM ROLE:
// • High-throughput event ingestion
// • Low-cost civic activity logging  
// • Scalability buffer for peak loads
// • Future-proof expansion layer
// 
// OPTIMISM ROLE (Primary):
// • Canonical trust layer
// • Final attestations
// • Proof-of-Resolution anchoring
// • Source of truth for governance
// 
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 
// STATUS: Phase 1 - Read-Only Integration
// 
// IMPLEMENTED NOW:
// ✓ Network configuration (testnet)
// ✓ Read-only provider service
// ✓ Connection status checking
// ✓ Chain information retrieval
// ✓ Architecture documentation
// 
// ARCHITECTURALLY PLANNED:
// ○ Event logging (when enabled)
// ○ Activity metric aggregation
// ○ Cross-chain event verification
// ○ Optimism finality confirmation
// 
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Core
export 'shardeum_network_config.dart';
export 'shardeum_service.dart';
export 'shardeum_transaction_service.dart';

// Presentation
export 'presentation/bloc/shardeum_bloc.dart';
export 'presentation/bloc/transaction_log_bloc.dart';
export 'presentation/screens/shardeum_screen.dart';
export 'presentation/screens/transaction_log_screen.dart';
