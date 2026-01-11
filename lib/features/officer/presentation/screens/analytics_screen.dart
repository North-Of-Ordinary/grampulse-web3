import 'package:flutter/material.dart';

class OfficerAnalyticsScreen extends StatefulWidget {
  const OfficerAnalyticsScreen({super.key});

  @override
  State<OfficerAnalyticsScreen> createState() => _OfficerAnalyticsScreenState();
}

class _OfficerAnalyticsScreenState extends State<OfficerAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Time Period',
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => ['This Week', 'This Month', 'This Quarter', 'This Year'].map((p) => PopupMenuItem(value: p, child: Row(children: [if (_selectedPeriod == p) const Icon(Icons.check, size: 18), const SizedBox(width: 8), Text(p)]))).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCategoriesTab(),
          _buildPerformanceTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
            child: Text(_selectedPeriod, style: TextStyle(color: isDark ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          
          // Key Metrics
          Text('Key Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _MetricCard(title: 'Total Issues', value: '156', change: '+12%', isPositive: false, icon: Icons.assignment),
              _MetricCard(title: 'Resolved', value: '128', change: '+18%', isPositive: true, icon: Icons.check_circle),
              _MetricCard(title: 'Avg Resolution', value: '3.2 days', change: '-15%', isPositive: true, icon: Icons.timer),
              _MetricCard(title: 'Satisfaction', value: '87%', change: '+5%', isPositive: true, icon: Icons.thumb_up),
            ],
          ),
          const SizedBox(height: 24),
          
          // Weekly Trend Chart (simplified)
          Text('Weekly Resolution Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BarChartItem(height: 0.6, label: 'Mon', value: '18'),
                      _BarChartItem(height: 0.8, label: 'Tue', value: '24'),
                      _BarChartItem(height: 0.5, label: 'Wed', value: '15'),
                      _BarChartItem(height: 0.9, label: 'Thu', value: '27'),
                      _BarChartItem(height: 0.7, label: 'Fri', value: '21'),
                      _BarChartItem(height: 0.4, label: 'Sat', value: '12'),
                      _BarChartItem(height: 0.3, label: 'Sun', value: '9'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Status Distribution
          Text('Issue Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Column(
              children: [
                _StatusDistributionRow(label: 'Resolved', value: 128, total: 156, color: Colors.green),
                const SizedBox(height: 12),
                _StatusDistributionRow(label: 'In Progress', value: 18, total: 156, color: Colors.grey),
                const SizedBox(height: 12),
                _StatusDistributionRow(label: 'Pending', value: 10, total: 156, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      _CategoryData(name: 'Infrastructure', count: 45, percentage: 29, trend: '+8%', color: Colors.blue),
      _CategoryData(name: 'Water Supply', count: 38, percentage: 24, trend: '+12%', color: Colors.cyan),
      _CategoryData(name: 'Sanitation', count: 28, percentage: 18, trend: '-5%', color: Colors.green),
      _CategoryData(name: 'Electrical', count: 22, percentage: 14, trend: '+3%', color: Colors.orange),
      _CategoryData(name: 'Public Spaces', count: 15, percentage: 10, trend: '0%', color: Colors.purple),
      _CategoryData(name: 'Others', count: 8, percentage: 5, trend: '-2%', color: Colors.grey),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie Chart representation
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Row(
              children: [
                // Simplified pie chart
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 20,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('156', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                          Text('Total', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Legend
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.take(4).map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 8),
                        Text(c.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Category breakdown
          Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          ...categories.map((c) => _CategoryCard(category: c)),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Performance Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('92', style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.only(bottom: 8), child: Text('/100', style: TextStyle(color: Colors.white70, fontSize: 20))),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Excellent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Performance metrics
          Text('Performance Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          _PerformanceMetricTile(title: 'Resolution Rate', value: '82%', target: '80%', achieved: true, icon: Icons.check_circle_outline),
          _PerformanceMetricTile(title: 'Avg Response Time', value: '2.5 hrs', target: '4 hrs', achieved: true, icon: Icons.access_time),
          _PerformanceMetricTile(title: 'On-time Completion', value: '78%', target: '85%', achieved: false, icon: Icons.event_available),
          _PerformanceMetricTile(title: 'Citizen Satisfaction', value: '87%', target: '80%', achieved: true, icon: Icons.sentiment_satisfied),
          _PerformanceMetricTile(title: 'Issues Handled', value: '156', target: '150', achieved: true, icon: Icons.assignment_turned_in),
          
          const SizedBox(height: 24),
          
          // Comparison with team
          Text('Team Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Column(
              children: [
                _TeamMemberRow(rank: 1, name: 'You', score: 92, isCurrentUser: true),
                const Divider(),
                _TeamMemberRow(rank: 2, name: 'Officer Kumar', score: 88, isCurrentUser: false),
                const Divider(),
                _TeamMemberRow(rank: 3, name: 'Officer Singh', score: 85, isCurrentUser: false),
                const Divider(),
                _TeamMemberRow(rank: 4, name: 'Officer Sharma', score: 82, isCurrentUser: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const _MetricCard({required this.title, required this.value, required this.change, required this.isPositive, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: isPositive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(change, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _BarChartItem extends StatelessWidget {
  final double height;
  final String label;
  final String value;

  const _BarChartItem({required this.height, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 100 * height,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade600 : Theme.of(context).colorScheme.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      ],
    );
  }
}

class _StatusDistributionRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _StatusDistributionRow({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (value / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : null)),
            Text('$value (${(percentage * 100).toInt()}%)', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _CategoryData {
  final String name;
  final int count;
  final int percentage;
  final String trend;
  final Color color;

  _CategoryData({required this.name, required this.count, required this.percentage, required this.trend, required this.color});
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = category.trend.startsWith('+');
    final isNeutral = category.trend == '0%';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? const Color(0xFF1A1A1A) : null,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: Color(0xFF2D2D2D)) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: category.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('${category.percentage}%', style: TextStyle(color: category.color, fontWeight: FontWeight.bold, fontSize: 12))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : null)),
                  Text('${category.count} issues', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isNeutral ? Colors.grey.withOpacity(0.15) : (isPositive ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isNeutral) Icon(isPositive ? Icons.trending_up : Icons.trending_down, size: 14, color: isPositive ? Colors.red : Colors.green),
                  const SizedBox(width: 4),
                  Text(category.trend, style: TextStyle(color: isNeutral ? Colors.grey : (isPositive ? Colors.red : Colors.green), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String target;
  final bool achieved;
  final IconData icon;

  const _PerformanceMetricTile({required this.title, required this.value, required this.target, required this.achieved, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? const Color(0xFF1A1A1A) : null,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: Color(0xFF2D2D2D)) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: (achieved ? Colors.green : Colors.orange).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: achieved ? Colors.green : Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : null)),
                  Text('Target: $target', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : null)),
                Icon(achieved ? Icons.check_circle : Icons.warning_amber, color: achieved ? Colors.green : Colors.orange, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;

  const _TeamMemberRow({required this.rank, required this.name, required this.score, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey.shade400 : (rank == 3 ? Colors.brown.shade300 : Colors.grey.shade200)),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text('$rank', style: TextStyle(color: rank <= 3 ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal, color: isCurrentUser ? Theme.of(context).colorScheme.primary : null)),
          ),
          Text('$score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isCurrentUser ? Theme.of(context).colorScheme.primary : null)),
        ],
      ),
    );
  }
}
