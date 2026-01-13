/// IncoDocs Overview - Economic & Compliance Enablement Layer
/// 
/// "Verified villages unlock trade confidence"
/// 
/// This module provides curated content and guidance for rural economic
/// enablement through verified governance. It consumes trust signals from
/// Optimism attestations and translates them into trade-readiness indicators.
/// 
/// IMPORTANT: This is NOT a certification system.
/// It provides AWARENESS and READINESS indicators only.

class IncoOverview {
  // ═══════════════════════════════════════════════════════════════════
  // STATIC CONTENT - EXPORT READINESS
  // ═══════════════════════════════════════════════════════════════════
  
  static const String exportReadinessTitle = 'Export Readiness';
  
  static const String exportReadinessDescription = '''
Export readiness represents a village's preparedness to participate in 
formal trade channels. This is built through:

• Verified governance activities
• Consistent civic participation
• Documented resolution processes
• Transparent decision-making

A village with strong governance signals demonstrates the institutional 
reliability that trade partners seek.
''';

  static const List<ExportReadinessLevel> exportReadinessLevels = [
    ExportReadinessLevel(
      level: 'Foundation',
      description: 'Basic governance structures established',
      requirements: [
        'Minimum 10 verified participants',
        'At least 1 resolved issue',
        'Active governance forum',
      ],
      tradeImplication: 'Eligible for local market participation',
    ),
    ExportReadinessLevel(
      level: 'Developing',
      description: 'Consistent governance activity demonstrated',
      requirements: [
        '50+ verified participants',
        '10+ resolved issues with attestations',
        'Regular governance meetings documented',
        'Dispute resolution process active',
      ],
      tradeImplication: 'Eligible for regional trade partnerships',
    ),
    ExportReadinessLevel(
      level: 'Established',
      description: 'Strong governance track record',
      requirements: [
        '200+ verified participants',
        '50+ attested resolutions',
        'Sustainability metrics tracked',
        'External verification completed',
      ],
      tradeImplication: 'Eligible for national supply chain integration',
    ),
    ExportReadinessLevel(
      level: 'Advanced',
      description: 'Exemplary governance excellence',
      requirements: [
        '500+ verified participants',
        '100+ attested resolutions',
        'High Village Sustainability Index (VSI)',
        'Multi-year governance history',
        'Zero unresolved disputes',
      ],
      tradeImplication: 'Eligible for international trade consideration',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // STATIC CONTENT - TRADE DOCUMENTATION AWARENESS
  // ═══════════════════════════════════════════════════════════════════
  
  static const String tradeDocumentationTitle = 'Trade Documentation Awareness';
  
  static const String tradeDocumentationDescription = '''
Understanding trade documentation is essential for villages seeking to 
participate in formal economic channels. While GramPulse does not generate 
these documents, verified governance creates the trust foundation that 
makes documentation meaningful.
''';

  static const List<TradeDocumentCategory> documentCategories = [
    TradeDocumentCategory(
      name: 'Origin Documentation',
      description: 'Proves where products come from',
      relevance: 'Verified village identity strengthens origin claims',
      examples: [
        'Certificate of Origin',
        'Geographic Indication documentation',
        'Producer organization registration',
      ],
      futureCapability: 'Attestation-backed origin verification',
    ),
    TradeDocumentCategory(
      name: 'Quality Documentation',
      description: 'Demonstrates product standards',
      relevance: 'Governance transparency supports quality claims',
      examples: [
        'Quality inspection reports',
        'Processing standards compliance',
        'Storage and handling records',
      ],
      futureCapability: 'On-chain quality attestation trails',
    ),
    TradeDocumentCategory(
      name: 'Compliance Documentation',
      description: 'Shows regulatory adherence',
      relevance: 'Strong governance indicates compliance capability',
      examples: [
        'Environmental compliance certificates',
        'Labor practice documentation',
        'Safety standards certification',
      ],
      futureCapability: 'Verifiable compliance attestations',
    ),
    TradeDocumentCategory(
      name: 'Financial Documentation',
      description: 'Supports trade financing',
      relevance: 'Governance track record builds creditworthiness',
      examples: [
        'Invoice and payment records',
        'Banking documentation',
        'Trade credit history',
      ],
      futureCapability: 'Governance-backed credit scoring',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // STATIC CONTENT - MARKET ACCESS EXPLANATION
  // ═══════════════════════════════════════════════════════════════════
  
  static const String marketAccessTitle = 'Market Access Pathways';
  
  static const String marketAccessDescription = '''
Market access for rural producers depends on demonstrating reliability, 
consistency, and trustworthiness. Traditional verification is expensive 
and excludes small producers. Blockchain-verified governance offers a 
new pathway.
''';

  static const List<MarketAccessPathway> marketPathways = [
    MarketAccessPathway(
      market: 'Local Markets',
      requirement: 'Basic trust and reputation',
      howGovernanceHelps: 'Visible community participation builds local trust',
      accessLevel: 'immediate',
    ),
    MarketAccessPathway(
      market: 'Regional Aggregators',
      requirement: 'Consistent supply and quality signals',
      howGovernanceHelps: 'Attested governance shows organizational stability',
      accessLevel: 'short-term',
    ),
    MarketAccessPathway(
      market: 'National Supply Chains',
      requirement: 'Compliance capability and track record',
      howGovernanceHelps: 'Verifiable resolution history demonstrates reliability',
      accessLevel: 'medium-term',
    ),
    MarketAccessPathway(
      market: 'Export Markets',
      requirement: 'International standards and documentation',
      howGovernanceHelps: 'Transparent governance satisfies due diligence requirements',
      accessLevel: 'long-term',
    ),
    MarketAccessPathway(
      market: 'Fair Trade Channels',
      requirement: 'Democratic governance and fair practices',
      howGovernanceHelps: 'On-chain governance proofs align with fair trade principles',
      accessLevel: 'medium-term',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // RURAL IMPACT FRAMING
  // ═══════════════════════════════════════════════════════════════════
  
  static const String ruralImpactStatement = '''
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║           "VERIFIED VILLAGES UNLOCK TRADE CONFIDENCE"                 ║
║                                                                       ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  Traditional Challenge:                                               ║
║  Rural producers lack the documentation and verification              ║
║  infrastructure to participate in formal trade channels.              ║
║                                                                       ║
║  GramPulse Solution:                                                  ║
║  Blockchain-verified governance creates a portable, tamper-proof      ║
║  record of community trustworthiness.                                 ║
║                                                                       ║
║  Economic Impact:                                                     ║
║  • Reduced verification costs for trade partners                      ║
║  • Lower barriers to market entry                                     ║
║  • Transparent track record for credit access                         ║
║  • Foundation for formal economic participation                       ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
''';

  // ═══════════════════════════════════════════════════════════════════
  // DISCLAIMER & FUTURE CAPABILITY
  // ═══════════════════════════════════════════════════════════════════
  
  static const String disclaimer = '''
IMPORTANT DISCLAIMER:

IncoDocs integration provides AWARENESS and GUIDANCE only.

• This is NOT a certification system
• We do NOT issue trade documents  
• We do NOT guarantee market access
• We do NOT automate compliance

What we provide:
• Educational content on trade requirements
• Visibility into governance-to-trade pathway
• Readiness indicators based on verified activity
• Framework for future economic enablement

This represents a FUTURE CAPABILITY being architecturally prepared.
''';

  static const String futureCapabilityStatement = '''
FUTURE CAPABILITY (Architecturally Planned):

Phase 2: Readiness Assessment
• Automated VSI-to-trade-readiness mapping
• Attestation count thresholds for market tiers
• Partner matching based on governance strength

Phase 3: Documentation Support  
• Template generation for common trade docs
• Attestation integration into documentation
• Verification QR codes for physical documents

Phase 4: Market Connection
• Direct aggregator introductions
• Trade partner discovery
• Supply chain integration APIs

Current Status: Phase 1 - Awareness & Education
''';
}

// ═══════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════

class ExportReadinessLevel {
  final String level;
  final String description;
  final List<String> requirements;
  final String tradeImplication;

  const ExportReadinessLevel({
    required this.level,
    required this.description,
    required this.requirements,
    required this.tradeImplication,
  });
}

class TradeDocumentCategory {
  final String name;
  final String description;
  final String relevance;
  final List<String> examples;
  final String futureCapability;

  const TradeDocumentCategory({
    required this.name,
    required this.description,
    required this.relevance,
    required this.examples,
    required this.futureCapability,
  });
}

class MarketAccessPathway {
  final String market;
  final String requirement;
  final String howGovernanceHelps;
  final String accessLevel; // immediate, short-term, medium-term, long-term

  const MarketAccessPathway({
    required this.market,
    required this.requirement,
    required this.howGovernanceHelps,
    required this.accessLevel,
  });
}
