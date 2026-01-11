import 'package:flutter/material.dart';

/// Enum to define user roles for help content filtering
enum HelpUserRole { citizen, volunteer, officer }

class HelpSupportScreen extends StatelessWidget {
  final String userRole;
  
  const HelpSupportScreen({super.key, required this.userRole});

  HelpUserRole get _role {
    switch (userRole.toLowerCase()) {
      case 'volunteer':
        return HelpUserRole.volunteer;
      case 'officer':
        return HelpUserRole.officer;
      default:
        return HelpUserRole.citizen;
    }
  }

  String get _roleDisplayName {
    switch (_role) {
      case HelpUserRole.volunteer:
        return 'Volunteer';
      case HelpUserRole.officer:
        return 'Officer';
      case HelpUserRole.citizen:
        return 'Citizen';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(context, isDark, colorScheme),
            const SizedBox(height: 24),

            // User Manual Section
            _buildSectionTitle(context, 'User Manual', isDark),
            const SizedBox(height: 12),
            _buildUserManualSection(context, isDark, colorScheme),
            const SizedBox(height: 24),

            // Features by Version Section
            _buildSectionTitle(context, 'Features by App Version', isDark),
            const SizedBox(height: 12),
            _buildVersionFeaturesSection(context, isDark, colorScheme),
            const SizedBox(height: 24),

            // FAQ Section
            _buildSectionTitle(context, 'Frequently Asked Questions', isDark),
            const SizedBox(height: 12),
            _buildFAQSection(context, isDark, colorScheme),
            const SizedBox(height: 24),

            // Contact Support
            _buildSectionTitle(context, 'Contact Support', isDark),
            const SizedBox(height: 12),
            _buildContactSection(context, isDark, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: isDark ? Colors.blue.shade400 : colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$_roleDisplayName Mode',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getRoleColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getWelcomeDescription(),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor() {
    switch (_role) {
      case HelpUserRole.volunteer:
        return Colors.green;
      case HelpUserRole.officer:
        return Colors.blue;
      case HelpUserRole.citizen:
        return Colors.orange;
    }
  }

  String _getWelcomeDescription() {
    switch (_role) {
      case HelpUserRole.citizen:
        return 'Learn how to report issues, track your submissions, and stay informed about your community.';
      case HelpUserRole.volunteer:
        return 'Discover how to verify reports, assist citizens, and track your volunteer performance.';
      case HelpUserRole.officer:
        return 'Learn how to manage assigned issues, review reports, and monitor resolution progress.';
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildUserManualSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    final manualItems = _getManualItemsForRole();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: manualItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildManualExpansionTile(
            context,
            item,
            isDark,
            colorScheme,
            showDivider: index < manualItems.length - 1,
          );
        }).toList(),
      ),
    );
  }

  List<_ManualItem> _getManualItemsForRole() {
    // Common items for all roles
    final commonItems = [
      _ManualItem(
        icon: Icons.person_outline,
        title: 'Managing Your Profile',
        steps: [
          'Tap the "Profile" tab in the navigation.',
          'Update your personal information.',
          'Manage notification preferences.',
          'View your activity history.',
          'Change app settings and theme.',
        ],
      ),
    ];

    switch (_role) {
      case HelpUserRole.citizen:
        return [
          _ManualItem(
            icon: Icons.report_problem_outlined,
            title: 'Reporting Issues',
            steps: [
              'Tap the "Report" tab from the bottom navigation.',
              'Select the type of issue you want to report.',
              'Provide a clear description of the problem.',
              'Add photos or location to help identify the issue.',
              'Submit your report and track its status.',
            ],
          ),
          _ManualItem(
            icon: Icons.track_changes_outlined,
            title: 'Tracking Your Reports',
            steps: [
              'Go to "My Reports" from the home screen.',
              'View all your submitted reports and their status.',
              'Tap on any report to see detailed updates.',
              'Receive notifications when status changes.',
            ],
          ),
          _ManualItem(
            icon: Icons.campaign_outlined,
            title: 'Viewing Announcements',
            steps: [
              'Access announcements from the home screen.',
              'Browse official updates from local authorities.',
              'Filter by category or date.',
              'Save important announcements for later.',
            ],
          ),
          _ManualItem(
            icon: Icons.map_outlined,
            title: 'Using the Map',
            steps: [
              'Access the map from the home screen.',
              'View nearby reported issues.',
              'Tap markers for issue details.',
              'Use filters to show specific issue types.',
            ],
          ),
          ...commonItems,
        ];

      case HelpUserRole.volunteer:
        return [
          _ManualItem(
            icon: Icons.verified_outlined,
            title: 'Verifying Reports',
            steps: [
              'Go to "Verification Queue" from the dashboard.',
              'Review pending reports in your assigned area.',
              'Visit the location to verify the issue.',
              'Add verification notes and photos.',
              'Submit your verification decision.',
            ],
          ),
          _ManualItem(
            icon: Icons.support_agent_outlined,
            title: 'Assisting Citizens',
            steps: [
              'Navigate to "Assist Citizen" from the menu.',
              'Help citizens with government scheme applications.',
              'Guide them through digital services.',
              'Record assistance provided for tracking.',
            ],
          ),
          _ManualItem(
            icon: Icons.analytics_outlined,
            title: 'Tracking Your Performance',
            steps: [
              'Go to "Stats" tab to view your performance.',
              'Monitor verifications completed.',
              'Track citizens helped and response time.',
              'View your ranking among area volunteers.',
            ],
          ),
          _ManualItem(
            icon: Icons.map_outlined,
            title: 'Using the Area Map',
            steps: [
              'Access the map to see issues in your area.',
              'View pending verifications nearby.',
              'Plan efficient routes for site visits.',
              'Mark locations as verified.',
            ],
          ),
          ...commonItems,
        ];

      case HelpUserRole.officer:
        return [
          _ManualItem(
            icon: Icons.inbox_outlined,
            title: 'Managing Your Inbox',
            steps: [
              'Access "Inbox" to see assigned issues.',
              'Review issue details and verification status.',
              'Prioritize based on urgency and impact.',
              'Assign work orders for resolution.',
            ],
          ),
          _ManualItem(
            icon: Icons.work_outline,
            title: 'Creating Work Orders',
            steps: [
              'Go to "Work Orders" from the dashboard.',
              'Create new work orders for verified issues.',
              'Assign resources and set deadlines.',
              'Track work order progress.',
            ],
          ),
          _ManualItem(
            icon: Icons.analytics_outlined,
            title: 'Viewing Analytics',
            steps: [
              'Navigate to "Analytics" for insights.',
              'Monitor resolution rates and trends.',
              'View category-wise issue distribution.',
              'Generate reports for stakeholders.',
            ],
          ),
          _ManualItem(
            icon: Icons.check_circle_outline,
            title: 'Resolving Issues',
            steps: [
              'Review completed work orders.',
              'Verify resolution with photos/notes.',
              'Update issue status to resolved.',
              'Notify citizens of resolution.',
            ],
          ),
          ...commonItems,
        ];
    }
  }

  Widget _buildManualExpansionTile(
    BuildContext context,
    _ManualItem item,
    bool isDark,
    ColorScheme colorScheme, {
    bool showDivider = true,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.blue.shade400 : colorScheme.primary).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: isDark ? Colors.blue.shade400 : colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconColor: isDark ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
        collapsedIconColor: isDark ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0D0D) : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.steps.asMap().entries.map((entry) {
                final stepIndex = entry.key;
                final step = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: stepIndex < item.steps.length - 1 ? 8 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.blue.shade400 : colorScheme.primary).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.blue.shade400 : colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFeaturesSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    final versions = _getVersionFeaturesForRole();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: versions.asMap().entries.map((entry) {
          final index = entry.key;
          final version = entry.value;
          return _buildVersionTile(
            context,
            version,
            isDark,
            colorScheme,
            showDivider: index < versions.length - 1,
          );
        }).toList(),
      ),
    );
  }

  List<_VersionInfo> _getVersionFeaturesForRole() {
    switch (_role) {
      case HelpUserRole.citizen:
        return [
          _VersionInfo(
            version: '2.0.2',
            releaseDate: 'December 2025',
            isCurrent: true,
            features: [
              'Enhanced dark theme with Grok-style design',
              'Improved issue tracking interface',
              'Better accessibility and UI consistency',
              'Bug fixes and stability improvements',
            ],
          ),
          _VersionInfo(
            version: '2.0.0',
            releaseDate: 'November 2025',
            isCurrent: false,
            features: [
              'Real-time issue tracking and updates',
              'Interactive map with issue markers',
              'Push notifications for status updates',
              'Enhanced reporting workflow',
            ],
          ),
          _VersionInfo(
            version: '1.5.0',
            releaseDate: 'September 2025',
            isCurrent: false,
            features: [
              'Government scheme information',
              'Document upload for reports',
              'Location-based services',
              'Improved announcement viewing',
            ],
          ),
          _VersionInfo(
            version: '1.0.0',
            releaseDate: 'June 2025',
            isCurrent: false,
            features: [
              'Initial release',
              'Basic issue reporting',
              'User registration and profile',
              'Announcement viewing',
            ],
          ),
        ];

      case HelpUserRole.volunteer:
        return [
          _VersionInfo(
            version: '2.0.2',
            releaseDate: 'December 2025',
            isCurrent: true,
            features: [
              'Enhanced dark theme with Grok-style design',
              'Improved performance dashboard',
              'Better Stats page layout',
              'Bug fixes and stability improvements',
            ],
          ),
          _VersionInfo(
            version: '2.0.0',
            releaseDate: 'November 2025',
            isCurrent: false,
            features: [
              'Volunteer verification queue',
              'Citizen assistance features',
              'Performance tracking and rankings',
              'Push notifications for new assignments',
            ],
          ),
          _VersionInfo(
            version: '1.5.0',
            releaseDate: 'September 2025',
            isCurrent: false,
            features: [
              'Government scheme guidance tools',
              'Photo verification support',
              'Area-based task assignment',
            ],
          ),
          _VersionInfo(
            version: '1.0.0',
            releaseDate: 'June 2025',
            isCurrent: false,
            features: [
              'Initial volunteer features',
              'Basic verification workflow',
              'User profile management',
            ],
          ),
        ];

      case HelpUserRole.officer:
        return [
          _VersionInfo(
            version: '2.0.2',
            releaseDate: 'December 2025',
            isCurrent: true,
            features: [
              'Enhanced dark theme with Grok-style design',
              'Improved dashboard analytics',
              'Better UI consistency',
              'Bug fixes and stability improvements',
            ],
          ),
          _VersionInfo(
            version: '2.0.0',
            releaseDate: 'November 2025',
            isCurrent: false,
            features: [
              'Officer inbox and work orders',
              'Analytics dashboard',
              'Issue assignment workflow',
              'Push notifications for urgent issues',
            ],
          ),
          _VersionInfo(
            version: '1.5.0',
            releaseDate: 'September 2025',
            isCurrent: false,
            features: [
              'Resolution tracking',
              'Report generation',
              'Category-wise issue management',
            ],
          ),
          _VersionInfo(
            version: '1.0.0',
            releaseDate: 'June 2025',
            isCurrent: false,
            features: [
              'Initial officer features',
              'Basic issue management',
              'User profile management',
            ],
          ),
        ];
    }
  }

  Widget _buildVersionTile(
    BuildContext context,
    _VersionInfo version,
    bool isDark,
    ColorScheme colorScheme, {
    bool showDivider = true,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: version.isCurrent
                ? (isDark ? Colors.green.shade400 : Colors.green).withOpacity(0.15)
                : (isDark ? Colors.grey.shade600 : Colors.grey).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'v${version.version}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: version.isCurrent
                  ? (isDark ? Colors.green.shade400 : Colors.green.shade700)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Version ${version.version}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            if (version.isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CURRENT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          version.releaseDate,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        iconColor: isDark ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
        collapsedIconColor: isDark ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0D0D) : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: version.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: isDark ? Colors.green.shade400 : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    final faqs = _getFAQsForRole();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return _buildFAQTile(
            context,
            faq,
            isDark,
            colorScheme,
            showDivider: index < faqs.length - 1,
          );
        }).toList(),
      ),
    );
  }

  List<_FAQItem> _getFAQsForRole() {
    switch (_role) {
      case HelpUserRole.citizen:
        return [
          _FAQItem(
            question: 'How do I report an issue in my area?',
            answer: 'Navigate to the Report tab, select the issue category, provide details and photos, then submit. Your report will be sent to the relevant authorities.',
          ),
          _FAQItem(
            question: 'How can I track my reported issues?',
            answer: 'Go to "My Reports" from the home screen to see all your submissions and their current status. You\'ll also receive notifications for updates.',
          ),
          _FAQItem(
            question: 'What types of issues can I report?',
            answer: 'You can report infrastructure problems, water supply issues, sanitation concerns, public safety matters, and other civic issues in your area.',
          ),
          _FAQItem(
            question: 'How long does it take to resolve an issue?',
            answer: 'Resolution time varies based on issue complexity and priority. You can track progress through the app and will be notified of any status changes.',
          ),
          _FAQItem(
            question: 'Can I edit or delete my report after submission?',
            answer: 'You can add additional information to your report, but for deletion or major edits, please contact support.',
          ),
        ];

      case HelpUserRole.volunteer:
        return [
          _FAQItem(
            question: 'How do I verify a reported issue?',
            answer: 'Go to the Verification Queue, select an issue, visit the location, take verification photos, and submit your verification with notes.',
          ),
          _FAQItem(
            question: 'What happens after I verify an issue?',
            answer: 'Verified issues are forwarded to officers for action. You\'ll receive credit for the verification, which reflects in your performance stats.',
          ),
          _FAQItem(
            question: 'How can I help citizens with government schemes?',
            answer: 'Use the "Assist Citizen" feature to guide citizens through scheme eligibility and application processes. Record each assistance for tracking.',
          ),
          _FAQItem(
            question: 'How is my performance calculated?',
            answer: 'Performance is based on verifications completed, citizens helped, response time, and accuracy of your verifications.',
          ),
          _FAQItem(
            question: 'Can I choose which issues to verify?',
            answer: 'You can select from issues in your assigned area. Prioritize based on urgency and proximity for better efficiency.',
          ),
        ];

      case HelpUserRole.officer:
        return [
          _FAQItem(
            question: 'How do I manage my assigned issues?',
            answer: 'Access your Inbox to see all assigned issues. Review details, create work orders, and update status as resolution progresses.',
          ),
          _FAQItem(
            question: 'How do I create a work order?',
            answer: 'From an issue detail, tap "Create Work Order", assign resources, set deadlines, and track progress through the Work Orders section.',
          ),
          _FAQItem(
            question: 'How can I view analytics for my area?',
            answer: 'Navigate to Analytics to see resolution rates, issue trends, category distribution, and other performance metrics.',
          ),
          _FAQItem(
            question: 'How do I mark an issue as resolved?',
            answer: 'Once work is complete, update the issue status with resolution notes and photos. The citizen will be notified automatically.',
          ),
          _FAQItem(
            question: 'What if an issue needs to be reassigned?',
            answer: 'You can escalate or reassign issues through the issue detail page. Add notes explaining the reason for reassignment.',
          ),
        ];
    }
  }

  Widget _buildFAQTile(
    BuildContext context,
    _FAQItem faq,
    bool isDark,
    ColorScheme colorScheme, {
    bool showDivider = true,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(
          Icons.help_outline_rounded,
          color: isDark ? Colors.orange.shade400 : Colors.orange,
          size: 22,
        ),
        title: Text(
          faq.question,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconColor: isDark ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
        collapsedIconColor: isDark ? Colors.grey.shade400 : colorScheme.onSurfaceVariant,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0D0D) : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@grampulse.gov.in',
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            icon: Icons.phone_outlined,
            title: 'Helpline',
            subtitle: '1800-XXX-XXXX (Toll Free)',
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            icon: Icons.access_time_outlined,
            title: 'Support Hours',
            subtitle: 'Mon - Sat: 9:00 AM - 6:00 PM',
            isDark: isDark,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? Colors.blue.shade400 : colorScheme.primary).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.blue.shade400 : colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManualItem {
  final IconData icon;
  final String title;
  final List<String> steps;

  _ManualItem({
    required this.icon,
    required this.title,
    required this.steps,
  });
}

class _VersionInfo {
  final String version;
  final String releaseDate;
  final bool isCurrent;
  final List<String> features;

  _VersionInfo({
    required this.version,
    required this.releaseDate,
    required this.isCurrent,
    required this.features,
  });
}

class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({
    required this.question,
    required this.answer,
  });
}
