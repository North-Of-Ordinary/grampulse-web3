import 'package:flutter/material.dart';
import 'package:grampulse/core/services/supabase_service.dart';

class OfficerAnalyticsScreen extends StatefulWidget {
  const OfficerAnalyticsScreen({super.key});

  @override
  State<OfficerAnalyticsScreen> createState() => _OfficerAnalyticsScreenState();
}

class _OfficerAnalyticsScreenState extends State<OfficerAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final SupabaseService _supabase = SupabaseService();
  
  bool _isLoading = true;
  String? _error;
  
  // Analytics data
  int _totalIssues = 0;
  int _resolvedIssues = 0;
  int _inProgressIssues = 0;
  int _pendingIssues = 0;
  List<Map<String, dynamic>> _weeklyData = [];
  Map<String, int> _categoryData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final incidents = await _supabase.getAllIncidents();
      final stats = await _supabase.getIncidentStatistics();
      
      // Calculate totals
      _totalIssues = incidents.length;
      _resolvedIssues = incidents.where((i) => i['status'] == 'resolved' || i['status'] == 'closed').length;
      _inProgressIssues = incidents.where((i) => i['status'] == 'in_progress' || i['status'] == 'verified').length;
      _pendingIssues = incidents.where((i) => i['status'] == 'new' || i['status'] == 'submitted').length;
      
      // Calculate weekly data
      final now = DateTime.now();
      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekCounts = <int>[0, 0, 0, 0, 0, 0, 0];
      
      for (final incident in incidents) {
        try {
          final createdAt = DateTime.parse(incident['created_at'] ?? '');
          if (now.difference(createdAt).inDays < 7) {
            final dayIndex = (createdAt.weekday - 1) % 7;
            weekCounts[dayIndex]++;
          }
        } catch (_) {}
      }
      
      _weeklyData = List.generate(7, (i) => {'day': weekDays[i], 'count': weekCounts[i]});
      
      // Calculate category breakdown
      _categoryData = {};
      for (final incident in incidents) {
        final category = incident['category_name'] as String? ?? 'Other';
        _categoryData[category] = (_categoryData[category] ?? 0) + 1;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadAnalytics, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildOverviewTab(), _buildCategoriesTab(), _buildPerformanceTab()],
                  ),
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
              _MetricCard(title: 'Total Issues', value: '$_totalIssues', change: '', isPositive: false, icon: Icons.assignment),
              _MetricCard(title: 'Resolved', value: '$_resolvedIssues', change: _totalIssues > 0 ? '${((_resolvedIssues / _totalIssues) * 100).toInt()}%' : '0%', isPositive: true, icon: Icons.check_circle),
              _MetricCard(title: 'In Progress', value: '$_inProgressIssues', change: 'Active', isPositive: true, icon: Icons.autorenew),
              _MetricCard(title: 'Pending', value: '$_pendingIssues', change: 'New', isPositive: false, icon: Icons.pending_actions),
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
                    children: _weeklyData.map((data) {
                      final maxCount = _weeklyData.map((d) => d['count'] as int).fold(1, (a, b) => a > b ? a : b);
                      final height = maxCount > 0 ? (data['count'] as int) / maxCount : 0.0;
                      return _BarChartItem(height: height.toDouble(), label: data['day'] as String, value: '${data['count']}');
                    }).toList(),
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
                _StatusDistributionRow(label: 'Resolved', value: _resolvedIssues, total: _totalIssues > 0 ? _totalIssues : 1, color: Colors.green),
                const SizedBox(height: 12),
                _StatusDistributionRow(label: 'In Progress', value: _inProgressIssues, total: _totalIssues > 0 ? _totalIssues : 1, color: Colors.grey),
                const SizedBox(height: 12),
                _StatusDistributionRow(label: 'Pending', value: _pendingIssues, total: _totalIssues > 0 ? _totalIssues : 1, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [Colors.blue, Colors.cyan, Colors.green, Colors.orange, Colors.purple, Colors.grey];
    final total = _categoryData.values.fold(0, (a, b) => a + b);
    
    final categories = _categoryData.entries.map((entry) {
      final colorIndex = _categoryData.keys.toList().indexOf(entry.key) % colors.length;
      final percentage = total > 0 ? ((entry.value / total) * 100).toInt() : 0;
      return _CategoryData(
        name: entry.key,
        count: entry.value,
        percentage: percentage,
        trend: '',
        color: colors[colorIndex],
      );
    }).toList();
    
    // Sort by count descending
    categories.sort((a, b) => b.count.compareTo(a.count));

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
