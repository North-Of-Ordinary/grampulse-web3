/// IncoDocs Module - Economic & Compliance Enablement Layer
/// 
/// Architecture Summary:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 
/// "Verified villages unlock trade confidence"
/// 
/// INCODOCS ROLE:
/// • Knowledge & compliance awareness layer
/// • Downstream consumer of verified trust
/// • Trade-readiness indicator generation
/// • Economic opportunity mapping
/// 
/// INTEGRATION ARCHITECTURE:
/// ┌──────────────┐
/// │  OPTIMISM    │  ← Canonical trust layer (attestations)
/// │  (Primary)   │
/// └──────┬───────┘
///        │ Consumes verified governance data
///        ▼
/// ┌──────────────┐
/// │  INCODOCS    │  → Trade readiness indicators
/// │  (Consumer)  │  → Compliance confidence signals
/// │              │  → Economic opportunity mapping
/// └──────────────┘
/// 
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 
/// STATUS: Phase 1 - Awareness & Education
/// 
/// IMPLEMENTED NOW:
/// ✓ Static content (export readiness, documentation awareness)
/// ✓ Trade readiness assessment logic
/// ✓ Compliance confidence signal generation
/// ✓ Economic opportunity mapping
/// ✓ Read-only UI entry point
/// 
/// NOT IMPLEMENTED (By Design):
/// ✗ External API calls
/// ✗ Document generation
/// ✗ Certification claims
/// ✗ Automated compliance
/// 
/// ARCHITECTURALLY PLANNED:
/// ○ Phase 2: VSI-to-readiness automated mapping
/// ○ Phase 3: Template-based documentation support
/// ○ Phase 4: Market connection & partner discovery
/// 
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

library inco;

export 'inco_overview.dart';
export 'inco_enablement_service.dart';
export 'inco_enablement_screen.dart';
