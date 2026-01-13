import 'inco_overview.dart';

/// IncoDocs Enablement Service
/// 
/// This service consumes verified governance data and produces
/// trade-readiness indicators and compliance confidence signals.
/// 
/// IMPORTANT:
/// • NO external API calls
/// • NO automated document generation
/// • NO certification claims
/// • Pure logic and narrative output
/// 
/// "Verified villages unlock trade confidence"

class IncoEnablementService {
  // ═══════════════════════════════════════════════════════════════════
  // SINGLETON PATTERN
  // ═══════════════════════════════════════════════════════════════════
  
  static final IncoEnablementService _instance = IncoEnablementService._internal();
  factory IncoEnablementService() => _instance;
  IncoEnablementService._internal();

  // ═══════════════════════════════════════════════════════════════════
  // TRADE READINESS ASSESSMENT
  // ═══════════════════════════════════════════════════════════════════
  
  /// Calculate trade readiness based on governance metrics
  /// 
  /// Consumes:
  /// - Village Sustainability Index (VSI)
  /// - Optimism attestation counts
  /// - Participant count
  /// - Resolution history
  /// 
  /// Returns trade-readiness indicators (NOT certification)
  TradeReadinessAssessment assessTradeReadiness({
    required double villageSustainabilityIndex,
    required int attestationCount,
    required int verifiedParticipants,
    required int resolvedIssues,
    int unresolvedDisputes = 0,
    int governanceMonths = 0,
  }) {
    // Calculate component scores
    final vsiScore = _calculateVSIScore(villageSustainabilityIndex);
    final attestationScore = _calculateAttestationScore(attestationCount);
    final participationScore = _calculateParticipationScore(verifiedParticipants);
    final resolutionScore = _calculateResolutionScore(resolvedIssues, unresolvedDisputes);
    final maturityScore = _calculateMaturityScore(governanceMonths);

    // Weighted composite score
    final compositeScore = (
      vsiScore * 0.25 +
      attestationScore * 0.25 +
      participationScore * 0.20 +
      resolutionScore * 0.20 +
      maturityScore * 0.10
    );

    // Determine readiness level
    final level = _determineReadinessLevel(compositeScore);
    
    // Generate insights
    final insights = _generateReadinessInsights(
      vsiScore: vsiScore,
      attestationScore: attestationScore,
      participationScore: participationScore,
      resolutionScore: resolutionScore,
      maturityScore: maturityScore,
    );

    // Identify improvement areas
    final improvements = _identifyImprovementAreas(
      vsiScore: vsiScore,
      attestationScore: attestationScore,
      participationScore: participationScore,
      resolutionScore: resolutionScore,
      maturityScore: maturityScore,
    );

    return TradeReadinessAssessment(
      overallScore: compositeScore,
      level: level,
      vsiScore: vsiScore,
      attestationScore: attestationScore,
      participationScore: participationScore,
      resolutionScore: resolutionScore,
      maturityScore: maturityScore,
      insights: insights,
      improvements: improvements,
      eligibleMarkets: _getEligibleMarkets(level),
      assessedAt: DateTime.now(),
      disclaimer: IncoOverview.disclaimer,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMPLIANCE CONFIDENCE SIGNALS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Generate compliance confidence signals based on governance data
  /// 
  /// These are INDICATORS, not certifications.
  /// They represent how governance activity maps to compliance capability.
  ComplianceConfidenceSignals generateComplianceSignals({
    required int attestationCount,
    required int resolvedIssues,
    required int verifiedParticipants,
    required double villageSustainabilityIndex,
    bool hasDisputeResolution = false,
    bool hasRegularMeetings = false,
    bool hasTransparentVoting = false,
  }) {
    final signals = <ComplianceSignal>[];

    // Organizational Capability Signal
    signals.add(ComplianceSignal(
      category: 'Organizational Capability',
      strength: _calculateOrganizationalStrength(
        verifiedParticipants,
        hasRegularMeetings,
      ),
      evidence: 'Based on $verifiedParticipants verified participants',
      implication: 'Indicates capacity to maintain organizational standards',
    ));

    // Process Documentation Signal
    signals.add(ComplianceSignal(
      category: 'Process Documentation',
      strength: _calculateDocumentationStrength(
        attestationCount,
        resolvedIssues,
      ),
      evidence: 'Based on $attestationCount on-chain attestations',
      implication: 'Demonstrates ability to maintain verifiable records',
    ));

    // Dispute Resolution Signal
    signals.add(ComplianceSignal(
      category: 'Dispute Resolution',
      strength: hasDisputeResolution 
        ? SignalStrength.strong 
        : SignalStrength.developing,
      evidence: hasDisputeResolution 
        ? 'Active dispute resolution mechanism' 
        : 'Dispute resolution in development',
      implication: 'Affects ability to handle trade disagreements',
    ));

    // Governance Transparency Signal
    signals.add(ComplianceSignal(
      category: 'Governance Transparency',
      strength: hasTransparentVoting 
        ? SignalStrength.strong 
        : SignalStrength.moderate,
      evidence: hasTransparentVoting 
        ? 'On-chain voting record' 
        : 'Governance activity tracked',
      implication: 'Supports due diligence requirements',
    ));

    // Sustainability Signal
    signals.add(ComplianceSignal(
      category: 'Sustainability Practices',
      strength: _calculateSustainabilityStrength(villageSustainabilityIndex),
      evidence: 'VSI score: ${villageSustainabilityIndex.toStringAsFixed(1)}',
      implication: 'Relevant for ESG-focused trade partners',
    ));

    // Calculate overall confidence
    final overallConfidence = _calculateOverallConfidence(signals);

    return ComplianceConfidenceSignals(
      signals: signals,
      overallConfidence: overallConfidence,
      summary: _generateComplianceSummary(overallConfidence),
      disclaimer: 'These are confidence indicators, not compliance certifications.',
      generatedAt: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ECONOMIC OPPORTUNITY MAPPING
  // ═══════════════════════════════════════════════════════════════════
  
  /// Map governance strength to economic opportunities
  /// 
  /// Pure logic - no external API calls
  EconomicOpportunityMap mapEconomicOpportunities({
    required TradeReadinessAssessment readiness,
    required ComplianceConfidenceSignals compliance,
  }) {
    final opportunities = <EconomicOpportunity>[];

    // Local Market Opportunities
    opportunities.add(EconomicOpportunity(
      category: 'Local Markets',
      accessible: true,
      confidence: ConfidenceLevel.high,
      description: 'Direct sales to local buyers and cooperatives',
      governanceRequirement: 'Basic verified participation',
      currentStatus: 'Accessible with current governance level',
    ));

    // Regional Aggregator Opportunities
    final regionalAccessible = readiness.overallScore >= 40;
    opportunities.add(EconomicOpportunity(
      category: 'Regional Aggregators',
      accessible: regionalAccessible,
      confidence: regionalAccessible 
        ? ConfidenceLevel.moderate 
        : ConfidenceLevel.developing,
      description: 'Supply partnerships with regional collection centers',
      governanceRequirement: '50+ participants, 10+ attestations',
      currentStatus: regionalAccessible 
        ? 'May be accessible based on governance strength' 
        : 'Building towards eligibility',
    ));

    // Formal Supply Chain Opportunities
    final supplyChainAccessible = readiness.overallScore >= 60;
    opportunities.add(EconomicOpportunity(
      category: 'Formal Supply Chains',
      accessible: supplyChainAccessible,
      confidence: supplyChainAccessible 
        ? ConfidenceLevel.moderate 
        : ConfidenceLevel.low,
      description: 'Integration with organized retail and processing',
      governanceRequirement: 'Strong governance track record',
      currentStatus: supplyChainAccessible 
        ? 'Governance supports supply chain consideration' 
        : 'Requires continued governance building',
    ));

    // Export Consideration
    final exportConsiderable = readiness.overallScore >= 80;
    opportunities.add(EconomicOpportunity(
      category: 'Export Consideration',
      accessible: exportConsiderable,
      confidence: exportConsiderable 
        ? ConfidenceLevel.developing 
        : ConfidenceLevel.low,
      description: 'Foundation for international market exploration',
      governanceRequirement: 'Exemplary governance with multi-year history',
      currentStatus: exportConsiderable 
        ? 'Governance may support export due diligence' 
        : 'Long-term goal requiring sustained governance',
    ));

    // Fair Trade Alignment
    final fairTradeAligned = compliance.overallConfidence >= 0.6;
    opportunities.add(EconomicOpportunity(
      category: 'Fair Trade Alignment',
      accessible: fairTradeAligned,
      confidence: fairTradeAligned 
        ? ConfidenceLevel.moderate 
        : ConfidenceLevel.developing,
      description: 'Alignment with fair trade principles and channels',
      governanceRequirement: 'Democratic governance, transparent voting',
      currentStatus: fairTradeAligned 
        ? 'Governance aligns with fair trade principles' 
        : 'Building democratic governance foundations',
    ));

    return EconomicOpportunityMap(
      opportunities: opportunities,
      readinessLevel: readiness.level,
      complianceStrength: compliance.overallConfidence,
      recommendation: _generateOpportunityRecommendation(
        readiness.overallScore,
        compliance.overallConfidence,
      ),
      disclaimer: IncoOverview.futureCapabilityStatement,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // INTERNAL SCORING METHODS
  // ═══════════════════════════════════════════════════════════════════
  
  double _calculateVSIScore(double vsi) {
    // VSI is typically 0-100
    return (vsi / 100 * 100).clamp(0, 100);
  }

  double _calculateAttestationScore(int count) {
    if (count >= 100) return 100;
    if (count >= 50) return 80;
    if (count >= 20) return 60;
    if (count >= 10) return 40;
    if (count >= 5) return 20;
    return count * 4.0;
  }

  double _calculateParticipationScore(int participants) {
    if (participants >= 500) return 100;
    if (participants >= 200) return 80;
    if (participants >= 100) return 60;
    if (participants >= 50) return 40;
    if (participants >= 20) return 20;
    return participants * 1.0;
  }

  double _calculateResolutionScore(int resolved, int unresolved) {
    if (resolved == 0) return 0;
    final resolutionRate = resolved / (resolved + unresolved);
    final volumeBonus = (resolved / 50 * 20).clamp(0, 20);
    return (resolutionRate * 80 + volumeBonus).clamp(0, 100);
  }

  double _calculateMaturityScore(int months) {
    if (months >= 24) return 100;
    if (months >= 12) return 75;
    if (months >= 6) return 50;
    if (months >= 3) return 25;
    return months * 8.0;
  }

  String _determineReadinessLevel(double score) {
    if (score >= 80) return 'Advanced';
    if (score >= 60) return 'Established';
    if (score >= 40) return 'Developing';
    return 'Foundation';
  }

  List<String> _generateReadinessInsights({
    required double vsiScore,
    required double attestationScore,
    required double participationScore,
    required double resolutionScore,
    required double maturityScore,
  }) {
    final insights = <String>[];
    
    if (vsiScore >= 70) {
      insights.add('Strong sustainability practices support ESG-aligned partnerships');
    }
    if (attestationScore >= 70) {
      insights.add('Robust attestation history demonstrates verifiable governance');
    }
    if (participationScore >= 70) {
      insights.add('High participation indicates strong community engagement');
    }
    if (resolutionScore >= 70) {
      insights.add('Effective dispute resolution builds partner confidence');
    }
    if (maturityScore >= 70) {
      insights.add('Governance maturity supports long-term partnership consideration');
    }
    
    if (insights.isEmpty) {
      insights.add('Building foundational governance for future trade opportunities');
    }
    
    return insights;
  }

  List<String> _identifyImprovementAreas({
    required double vsiScore,
    required double attestationScore,
    required double participationScore,
    required double resolutionScore,
    required double maturityScore,
  }) {
    final improvements = <String>[];
    
    if (vsiScore < 50) {
      improvements.add('Focus on sustainability tracking to improve VSI');
    }
    if (attestationScore < 50) {
      improvements.add('Increase on-chain attestations for governance activities');
    }
    if (participationScore < 50) {
      improvements.add('Expand verified participant base');
    }
    if (resolutionScore < 50) {
      improvements.add('Resolve outstanding issues to demonstrate effectiveness');
    }
    if (maturityScore < 50) {
      improvements.add('Continue consistent governance activity over time');
    }
    
    return improvements;
  }

  List<String> _getEligibleMarkets(String level) {
    switch (level) {
      case 'Advanced':
        return [
          'Local Markets',
          'Regional Aggregators',
          'National Supply Chains',
          'Export Consideration',
          'Fair Trade Channels',
        ];
      case 'Established':
        return [
          'Local Markets',
          'Regional Aggregators',
          'National Supply Chains',
        ];
      case 'Developing':
        return [
          'Local Markets',
          'Regional Aggregators',
        ];
      default:
        return ['Local Markets'];
    }
  }

  SignalStrength _calculateOrganizationalStrength(
    int participants,
    bool hasRegularMeetings,
  ) {
    if (participants >= 200 && hasRegularMeetings) return SignalStrength.strong;
    if (participants >= 50) return SignalStrength.moderate;
    if (participants >= 20) return SignalStrength.developing;
    return SignalStrength.emerging;
  }

  SignalStrength _calculateDocumentationStrength(
    int attestations,
    int resolutions,
  ) {
    final total = attestations + resolutions;
    if (total >= 100) return SignalStrength.strong;
    if (total >= 50) return SignalStrength.moderate;
    if (total >= 20) return SignalStrength.developing;
    return SignalStrength.emerging;
  }

  SignalStrength _calculateSustainabilityStrength(double vsi) {
    if (vsi >= 80) return SignalStrength.strong;
    if (vsi >= 60) return SignalStrength.moderate;
    if (vsi >= 40) return SignalStrength.developing;
    return SignalStrength.emerging;
  }

  double _calculateOverallConfidence(List<ComplianceSignal> signals) {
    if (signals.isEmpty) return 0;
    
    final strengthValues = {
      SignalStrength.strong: 1.0,
      SignalStrength.moderate: 0.7,
      SignalStrength.developing: 0.4,
      SignalStrength.emerging: 0.2,
    };
    
    final total = signals.fold<double>(
      0,
      (sum, signal) => sum + (strengthValues[signal.strength] ?? 0),
    );
    
    return total / signals.length;
  }

  String _generateComplianceSummary(double confidence) {
    if (confidence >= 0.8) {
      return 'Strong governance indicators support compliance capability assessment';
    }
    if (confidence >= 0.6) {
      return 'Moderate governance indicators suggest developing compliance capability';
    }
    if (confidence >= 0.4) {
      return 'Building governance foundations for future compliance demonstration';
    }
    return 'Early-stage governance development in progress';
  }

  String _generateOpportunityRecommendation(
    double readinessScore,
    double complianceConfidence,
  ) {
    if (readinessScore >= 70 && complianceConfidence >= 0.7) {
      return '''
Your village demonstrates strong governance foundations. Consider:
• Engaging with regional aggregators
• Exploring formal supply chain partnerships
• Documenting your governance journey for trade partners
''';
    }
    
    if (readinessScore >= 50) {
      return '''
Your village is building solid governance. Focus on:
• Increasing attestation frequency
• Resolving any pending disputes
• Expanding verified participation
''';
    }
    
    return '''
Your village is establishing governance foundations. Prioritize:
• Consistent governance activities
• Documenting resolutions on-chain
• Building verified participant base
''';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════

class TradeReadinessAssessment {
  final double overallScore;
  final String level;
  final double vsiScore;
  final double attestationScore;
  final double participationScore;
  final double resolutionScore;
  final double maturityScore;
  final List<String> insights;
  final List<String> improvements;
  final List<String> eligibleMarkets;
  final DateTime assessedAt;
  final String disclaimer;

  TradeReadinessAssessment({
    required this.overallScore,
    required this.level,
    required this.vsiScore,
    required this.attestationScore,
    required this.participationScore,
    required this.resolutionScore,
    required this.maturityScore,
    required this.insights,
    required this.improvements,
    required this.eligibleMarkets,
    required this.assessedAt,
    required this.disclaimer,
  });

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'level': level,
    'scores': {
      'vsi': vsiScore,
      'attestation': attestationScore,
      'participation': participationScore,
      'resolution': resolutionScore,
      'maturity': maturityScore,
    },
    'insights': insights,
    'improvements': improvements,
    'eligibleMarkets': eligibleMarkets,
    'assessedAt': assessedAt.toIso8601String(),
  };
}

enum SignalStrength {
  strong,
  moderate,
  developing,
  emerging,
}

class ComplianceSignal {
  final String category;
  final SignalStrength strength;
  final String evidence;
  final String implication;

  ComplianceSignal({
    required this.category,
    required this.strength,
    required this.evidence,
    required this.implication,
  });
}

class ComplianceConfidenceSignals {
  final List<ComplianceSignal> signals;
  final double overallConfidence;
  final String summary;
  final String disclaimer;
  final DateTime generatedAt;

  ComplianceConfidenceSignals({
    required this.signals,
    required this.overallConfidence,
    required this.summary,
    required this.disclaimer,
    required this.generatedAt,
  });
}

enum ConfidenceLevel {
  high,
  moderate,
  developing,
  low,
}

class EconomicOpportunity {
  final String category;
  final bool accessible;
  final ConfidenceLevel confidence;
  final String description;
  final String governanceRequirement;
  final String currentStatus;

  EconomicOpportunity({
    required this.category,
    required this.accessible,
    required this.confidence,
    required this.description,
    required this.governanceRequirement,
    required this.currentStatus,
  });
}

class EconomicOpportunityMap {
  final List<EconomicOpportunity> opportunities;
  final String readinessLevel;
  final double complianceStrength;
  final String recommendation;
  final String disclaimer;

  EconomicOpportunityMap({
    required this.opportunities,
    required this.readinessLevel,
    required this.complianceStrength,
    required this.recommendation,
    required this.disclaimer,
  });
}
