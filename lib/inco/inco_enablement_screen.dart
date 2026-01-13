import 'package:flutter/material.dart';
import 'inco_overview.dart';
import 'inco_enablement_service.dart';

/// IncoDocs Economic Enablement Screen
/// 
/// A read-only, non-intrusive entry point for economic enablement features.
/// This screen displays curated content about trade readiness and compliance.
/// 
/// "Verified villages unlock trade confidence"

class IncoEnablementScreen extends StatefulWidget {
  /// Optional: Pre-loaded village data for assessment
  final VillageGovernanceData? villageData;

  const IncoEnablementScreen({
    super.key,
    this.villageData,
  });

  @override
  State<IncoEnablementScreen> createState() => _IncoEnablementScreenState();
}

class _IncoEnablementScreenState extends State<IncoEnablementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IncoEnablementService _service = IncoEnablementService();
  
  TradeReadinessAssessment? _assessment;
  ComplianceConfidenceSignals? _complianceSignals;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Generate assessment if village data provided
    if (widget.villageData != null) {
      _generateAssessment();
    }
  }

  void _generateAssessment() {
    final data = widget.villageData!;
    
    _assessment = _service.assessTradeReadiness(
      villageSustainabilityIndex: data.vsi,
      attestationCount: data.attestationCount,
      verifiedParticipants: data.verifiedParticipants,
      resolvedIssues: data.resolvedIssues,
      unresolvedDisputes: data.unresolvedDisputes,
      governanceMonths: data.governanceMonths,
    );

    _complianceSignals = _service.generateComplianceSignals(
      attestationCount: data.attestationCount,
      resolvedIssues: data.resolvedIssues,
      verifiedParticipants: data.verifiedParticipants,
      villageSustainabilityIndex: data.vsi,
      hasDisputeResolution: data.hasDisputeResolution,
      hasRegularMeetings: data.hasRegularMeetings,
      hasTransparentVoting: data.hasTransparentVoting,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Economic Enablement'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Readiness',
            ),
            Tab(
              icon: Icon(Icons.description_outlined),
              text: 'Documentation',
            ),
            Tab(
              icon: Icon(Icons.store_mall_directory),
              text: 'Markets',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Powered by IncoDocs banner
          _buildPoweredByBanner(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReadinessTab(),
                _buildDocumentationTab(),
                _buildMarketsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoweredByBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Economic Enablement powered by IncoDocs',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildInfoButton(),
        ],
      ),
    );
  }

  Widget _buildInfoButton() {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 20),
      onPressed: () => _showDisclaimerDialog(),
      tooltip: 'About IncoDocs',
    );
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('About IncoDocs'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '"Verified villages unlock trade confidence"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This module provides:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Educational content on trade requirements'),
              _buildBulletPoint('Readiness indicators based on governance'),
              _buildBulletPoint('Market access pathway guidance'),
              const SizedBox(height: 16),
              const Text(
                'This is NOT:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('A certification system'),
              _buildBulletPoint('Automated document generation'),
              _buildBulletPoint('Guaranteed market access'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text(
                  'This represents a future capability being architecturally prepared.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // READINESS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildReadinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            IncoOverview.exportReadinessTitle,
            Icons.trending_up,
          ),
          const SizedBox(height: 8),
          Text(
            IncoOverview.exportReadinessDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Assessment card if available
          if (_assessment != null) ...[
            _buildAssessmentCard(),
            const SizedBox(height: 24),
          ],
          
          // Readiness levels
          _buildSectionHeader('Readiness Levels', Icons.stairs),
          const SizedBox(height: 12),
          ...IncoOverview.exportReadinessLevels.map(
            (level) => _buildReadinessLevelCard(level),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard() {
    final assessment = _assessment!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Village Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreIndicator(
              'Overall Readiness',
              assessment.overallScore,
              assessment.level,
            ),
            const SizedBox(height: 12),
            _buildScoreBar('VSI Score', assessment.vsiScore),
            _buildScoreBar('Attestations', assessment.attestationScore),
            _buildScoreBar('Participation', assessment.participationScore),
            _buildScoreBar('Resolution', assessment.resolutionScore),
            _buildScoreBar('Maturity', assessment.maturityScore),
            const SizedBox(height: 16),
            if (assessment.insights.isNotEmpty) ...[
              const Text(
                'Insights:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...assessment.insights.map(
                (insight) => _buildBulletPoint(insight),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String label, double score, String level) {
    final color = _getScoreColor(score);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                level,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${score.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.teal;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildReadinessLevelCard(ExportReadinessLevel level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getLevelIcon(level.level),
          color: _getLevelColor(level.level),
        ),
        title: Text(
          level.level,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(level.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requirements:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...level.requirements.map(
                  (req) => _buildBulletPoint(req),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getLevelColor(level.level).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: _getLevelColor(level.level),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          level.tradeImplication,
                          style: TextStyle(
                            color: _getLevelColor(level.level),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'Advanced':
        return Icons.emoji_events;
      case 'Established':
        return Icons.verified;
      case 'Developing':
        return Icons.trending_up;
      default:
        return Icons.foundation;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Advanced':
        return Colors.amber.shade700;
      case 'Established':
        return Colors.green;
      case 'Developing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DOCUMENTATION TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDocumentationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            IncoOverview.tradeDocumentationTitle,
            Icons.description_outlined,
          ),
          const SizedBox(height: 8),
          Text(
            IncoOverview.tradeDocumentationDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          ...IncoOverview.documentCategories.map(
            (category) => _buildDocumentCategoryCard(category),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCategoryCard(TradeDocumentCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getDocumentIcon(category.name),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(category.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'How governance helps: ${category.relevance}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Examples:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...category.examples.map(
                  (example) => _buildBulletPoint(example),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Future capability: ${category.futureCapability}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String name) {
    if (name.contains('Origin')) return Icons.place;
    if (name.contains('Quality')) return Icons.verified_user;
    if (name.contains('Compliance')) return Icons.gavel;
    if (name.contains('Financial')) return Icons.account_balance;
    return Icons.description;
  }

  // ═══════════════════════════════════════════════════════════════════
  // MARKETS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMarketsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            IncoOverview.marketAccessTitle,
            Icons.store_mall_directory,
          ),
          const SizedBox(height: 8),
          Text(
            IncoOverview.marketAccessDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Rural impact statement
          _buildRuralImpactCard(),
          const SizedBox(height: 24),
          
          // Market pathways
          _buildSectionHeader('Market Pathways', Icons.route),
          const SizedBox(height: 12),
          ...IncoOverview.marketPathways.map(
            (pathway) => _buildMarketPathwayCard(pathway),
          ),
        ],
      ),
    );
  }

  Widget _buildRuralImpactCard() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.eco,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              '"Verified villages unlock trade confidence"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Blockchain-verified governance creates a portable, tamper-proof '
              'record of community trustworthiness that trade partners recognize.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPathwayCard(MarketAccessPathway pathway) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMarketIcon(pathway.market),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pathway.market,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildAccessLevelChip(pathway.accessLevel),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Requirement',
              pathway.requirement,
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'How governance helps',
              pathway.howGovernanceHelps,
              Icons.lightbulb_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessLevelChip(String level) {
    final color = _getAccessLevelColor(level);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getAccessLevelColor(String level) {
    switch (level) {
      case 'immediate':
        return Colors.green;
      case 'short-term':
        return Colors.teal;
      case 'medium-term':
        return Colors.blue;
      case 'long-term':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMarketIcon(String market) {
    if (market.contains('Local')) return Icons.storefront;
    if (market.contains('Regional')) return Icons.hub;
    if (market.contains('National')) return Icons.business;
    if (market.contains('Export')) return Icons.flight_takeoff;
    if (market.contains('Fair Trade')) return Icons.handshake;
    return Icons.store;
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMMON WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// INPUT DATA MODEL
// ═══════════════════════════════════════════════════════════════════════

/// Village governance data for assessment
/// Pass this to IncoEnablementScreen to show personalized assessment
class VillageGovernanceData {
  final double vsi;
  final int attestationCount;
  final int verifiedParticipants;
  final int resolvedIssues;
  final int unresolvedDisputes;
  final int governanceMonths;
  final bool hasDisputeResolution;
  final bool hasRegularMeetings;
  final bool hasTransparentVoting;

  const VillageGovernanceData({
    required this.vsi,
    required this.attestationCount,
    required this.verifiedParticipants,
    required this.resolvedIssues,
    this.unresolvedDisputes = 0,
    this.governanceMonths = 0,
    this.hasDisputeResolution = false,
    this.hasRegularMeetings = false,
    this.hasTransparentVoting = false,
  });
}
