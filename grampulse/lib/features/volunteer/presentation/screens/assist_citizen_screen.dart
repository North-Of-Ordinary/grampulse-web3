import 'package:flutter/material.dart';

class AssistCitizenScreen extends StatelessWidget {
  const AssistCitizenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assist Citizens'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.green.shade600,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline, color: isDark ? Colors.green.shade400 : Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text('Help Citizens', style: TextStyle(color: isDark ? Colors.white : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Guide citizens through government schemes and services', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.white.withOpacity(0.9), fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Assistance categories
            const Text('How can you help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _AssistanceCard(title: 'Scheme Guidance', description: 'Help citizens understand and apply for government schemes', icon: Icons.assignment, color: Colors.blue, onTap: () => _showSchemeGuidance(context)),
                _AssistanceCard(title: 'Document Help', description: 'Assist with document verification and submission', icon: Icons.description, color: Colors.orange, onTap: () => _showDocumentHelp(context)),
                _AssistanceCard(title: 'SHG Support', description: 'Guide Self-Help Groups in their activities', icon: Icons.group, color: Colors.purple, onTap: () => _showSHGSupport(context)),
                _AssistanceCard(title: 'Training Sessions', description: 'Organize and conduct awareness sessions', icon: Icons.school, color: Colors.teal, onTap: () => _showTrainingSessions(context)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent assistance requests
            const Text('Recent Assistance Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _AssistanceRequestCard(
              citizenName: 'Ramesh Kumar',
              requestType: 'Scheme Application',
              description: 'Need help applying for PM-KISAN scheme',
              timeAgo: '15 min ago',
              urgency: 'High',
            ),
            _AssistanceRequestCard(
              citizenName: 'Lakshmi Devi',
              requestType: 'Document Verification',
              description: 'Help with Aadhaar-PAN linking process',
              timeAgo: '1 hour ago',
              urgency: 'Medium',
            ),
            _AssistanceRequestCard(
              citizenName: 'Village SHG Group',
              requestType: 'SHG Support',
              description: 'Need guidance on bank loan application',
              timeAgo: '2 hours ago',
              urgency: 'Low',
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showSchemeGuidance(BuildContext context) {
    _showFeatureSheet(context, 'Scheme Guidance', Icons.assignment, Colors.blue, [
      _SchemeItem('PM-KISAN', 'Direct income support for farmers', '₹6,000/year'),
      _SchemeItem('Ayushman Bharat', 'Health insurance coverage', '₹5 Lakh/year'),
      _SchemeItem('PM Awas Yojana', 'Housing assistance scheme', '₹1.5-2.5 Lakh'),
      _SchemeItem('MGNREGA', 'Employment guarantee scheme', '100 days work'),
    ]);
  }

  void _showDocumentHelp(BuildContext context) {
    _showFeatureSheet(context, 'Document Help', Icons.description, Colors.orange, [
      _SchemeItem('Aadhaar Services', 'New registration & updates', 'Free'),
      _SchemeItem('PAN Card', 'Application & correction', '₹110'),
      _SchemeItem('Ration Card', 'New application & updates', 'Free'),
      _SchemeItem('Caste Certificate', 'Apply online', 'Free'),
    ]);
  }

  void _showSHGSupport(BuildContext context) {
    _showFeatureSheet(context, 'SHG Support', Icons.group, Colors.purple, [
      _SchemeItem('Group Formation', 'Help form new SHGs', 'Training'),
      _SchemeItem('Bank Linkage', 'Connect SHGs to banks', 'Loan Support'),
      _SchemeItem('Livelihood Training', 'Skill development programs', 'Various'),
      _SchemeItem('Market Access', 'Help sell products', 'Networking'),
    ]);
  }

  void _showTrainingSessions(BuildContext context) {
    _showFeatureSheet(context, 'Training Sessions', Icons.school, Colors.teal, [
      _SchemeItem('Digital Literacy', 'Smartphone & internet basics', '2 hours'),
      _SchemeItem('Financial Literacy', 'Banking & savings awareness', '3 hours'),
      _SchemeItem('Health Awareness', 'Hygiene & nutrition education', '2 hours'),
      _SchemeItem('Rights Awareness', 'Legal rights & entitlements', '2 hours'),
    ]);
  }

  void _showFeatureSheet(BuildContext context, String title, IconData icon, Color color, List<_SchemeItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.description),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(item.benefit, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${item.name} details...')));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemeItem {
  final String name;
  final String description;
  final String benefit;
  _SchemeItem(this.name, this.description, this.benefit);
}

class _AssistanceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AssistanceCard({required this.title, required this.description, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1A1A1A) : null,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: Color(0xFF2D2D2D)) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : null)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistanceRequestCard extends StatelessWidget {
  final String citizenName;
  final String requestType;
  final String description;
  final String timeAgo;
  final String urgency;

  const _AssistanceRequestCard({required this.citizenName, required this.requestType, required this.description, required this.timeAgo, required this.urgency});

  Color _getUrgencyColor() {
    switch (urgency) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? const Color(0xFF1A1A1A) : null,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: Color(0xFF2D2D2D)) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: isDark ? Colors.blue.shade900 : Colors.blue.shade100, child: Text(citizenName[0], style: TextStyle(color: isDark ? Colors.blue.shade300 : Colors.blue.shade700, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(citizenName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                      Text(requestType, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getUrgencyColor().withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text(urgency, style: TextStyle(color: _getUrgencyColor(), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timeAgo, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)), child: const Text('Message', style: TextStyle(fontSize: 12))),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: () {}, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)), child: const Text('Help', style: TextStyle(fontSize: 12))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
