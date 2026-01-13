import 'package:flutter/material.dart';
import 'package:grampulse/core/services/supabase_service.dart';

class PerformanceMetric {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  PerformanceMetric({required this.title, required this.value, required this.change, required this.isPositive, required this.icon, required this.color});
}

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'This Month';
  final SupabaseService _supabase = SupabaseService();
  
  List<PerformanceMetric> metrics = [];
  List<Map<String, dynamic>> weeklyData = [];
  List<Map<String, dynamic>> recentActivities = [];
  Map<String, int> categoryBreakdown = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final incidents = await _supabase.getAllIncidents();
      final stats = await _supabase.getIncidentStatistics();

      // Calculate metrics from real data
      final totalVerified = incidents.where((i) => i['status'] == 'verified' || i['status'] == 'resolved').length;
      final totalInProgress = incidents.where((i) => i['status'] == 'in_progress').length;
      final totalNew = incidents.where((i) => i['status'] == 'new' || i['status'] == 'submitted').length;
      
      // Calculate weekly data from incidents
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

      // Calculate category breakdown
      final catBreakdown = <String, int>{};
      for (final incident in incidents) {
        final category = incident['category_name'] ?? 'Other';
        catBreakdown[category] = (catBreakdown[category] ?? 0) + 1;
      }

      // Get recent activities (last 5 resolved/verified incidents)
      final recentList = incidents
          .where((i) => i['status'] == 'verified' || i['status'] == 'resolved' || i['status'] == 'in_progress')
          .take(5)
          .toList();

      setState(() {
        metrics = [
          PerformanceMetric(title: 'Verifications', value: '$totalVerified', change: '+${totalVerified > 0 ? ((totalVerified / (incidents.isEmpty ? 1 : incidents.length)) * 100).toInt() : 0}%', isPositive: true, icon: Icons.verified, color: Colors.blue),
          PerformanceMetric(title: 'In Progress', value: '$totalInProgress', change: 'Active', isPositive: true, icon: Icons.pending_actions, color: Colors.orange),
          PerformanceMetric(title: 'Pending', value: '$totalNew', change: 'New', isPositive: false, icon: Icons.hourglass_empty, color: Colors.red),
          PerformanceMetric(title: 'Total Issues', value: '${incidents.length}', change: 'All time', isPositive: true, icon: Icons.assignment, color: Colors.purple),
        ];
        
        weeklyData = List.generate(7, (i) => {'day': weekDays[i], 'count': weekCounts[i]});
        recentActivities = recentList;
        categoryBreakdown = catBreakdown;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Unknown';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return 'Earlier';
    } catch (_) {
      return 'Unknown';
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
        title: const Text('Performance Dashboard'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedPeriod,
            onSelected: (value) => setState(() => selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'This Year', child: Text('This Year')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(selectedPeriod, style: TextStyle(color: colorScheme.onPrimary)), const Icon(Icons.arrow_drop_down)],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Analytics'), Tab(text: 'Rankings')],
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadPerformanceData, child: const Text('Retry')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPerformanceData,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildOverviewTab(), _buildAnalyticsTab(), _buildRankingsTab()],
                    ),
                  ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2),
            itemCount: metrics.length,
            itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
          ),
          const SizedBox(height: 24),
          
          // Weekly Activity Chart
          Text('Weekly Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((data) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${data['count']}', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Container(
                        height: ((data['count'] as int) * 4.0).clamp(0, 120),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 8),
                      Text(data['day'], style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent Activity
          Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 12),
          if (recentActivities.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No recent activity', style: TextStyle(color: Colors.grey)))
          else
            ...recentActivities.map((activity) => _ActivityItem(
              title: activity['title'] ?? 'Activity',
              subtitle: activity['location'] ?? activity['category_name'] ?? 'Unknown location',
              time: _getTimeAgo(activity['created_at']),
              icon: activity['status'] == 'verified' || activity['status'] == 'resolved' ? Icons.verified : Icons.pending,
              color: activity['status'] == 'verified' || activity['status'] == 'resolved' ? Colors.green : Colors.orange,
            )),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Breakdown
          Text('Activity by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 16),
          if (categoryBreakdown.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No category data available', style: TextStyle(color: Colors.grey)))
          else
            ...categoryBreakdown.entries.take(5).map((entry) {
              final total = categoryBreakdown.values.fold(0, (a, b) => a + b);
              final percentage = total > 0 ? ((entry.value / total) * 100).toInt() : 0;
              final colors = [Colors.blue, Colors.cyan, Colors.green, Colors.orange, Colors.grey];
              final colorIndex = categoryBreakdown.keys.toList().indexOf(entry.key) % colors.length;
              return _CategoryBar(category: entry.key, percentage: percentage, color: colors[colorIndex]);
            }),
          const SizedBox(height: 24),
          
          // Time Distribution
          Text('Most Active Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Column(
              children: [
                _TimeSlot(time: '9 AM - 12 PM', percentage: 40),
                _TimeSlot(time: '12 PM - 3 PM', percentage: 25),
                _TimeSlot(time: '3 PM - 6 PM', percentage: 20),
                _TimeSlot(time: '6 PM - 9 PM', percentage: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Rank Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.amber.shade600,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
            ),
            child: Column(
              children: [
                Icon(Icons.emoji_events, color: isDark ? Colors.amber.shade400 : Colors.white, size: 48),
                const SizedBox(height: 12),
                Text('Your Rank', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.white70, fontSize: 14)),
                Text('#5', style: TextStyle(color: isDark ? Colors.white : Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                Text('in your area', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: isDark ? Colors.amber.shade400.withOpacity(0.2) : Colors.white24, borderRadius: BorderRadius.circular(20)), child: Text('Top 10%', style: TextStyle(color: isDark ? Colors.amber.shade400 : Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Leaderboard
          Text('Area Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          const SizedBox(height: 16),
          _LeaderboardItem(rank: 1, name: 'Suresh Kumar', points: 892, isCurrentUser: false),
          _LeaderboardItem(rank: 2, name: 'Priya Sharma', points: 756, isCurrentUser: false),
          _LeaderboardItem(rank: 3, name: 'Amit Patel', points: 698, isCurrentUser: false),
          _LeaderboardItem(rank: 4, name: 'Meena Devi', points: 654, isCurrentUser: false),
          _LeaderboardItem(rank: 5, name: 'You', points: 612, isCurrentUser: true),
          _LeaderboardItem(rank: 6, name: 'Rajesh Singh', points: 589, isCurrentUser: false),
          _LeaderboardItem(rank: 7, name: 'Lakshmi Nair', points: 543, isCurrentUser: false),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final PerformanceMetric metric;
  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(metric.icon, color: metric.color, size: 22),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (metric.isPositive ? Colors.green : Colors.red).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(metric.change, style: TextStyle(color: metric.isPositive ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(metric.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null), overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 2),
          Text(metric.title, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  const _ActivityItem({required this.title, required this.subtitle, required this.time, required this.icon, required this.color});

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
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : null)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        trailing: Text(time, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String category;
  final int percentage;
  final Color color;
  const _CategoryBar({required this.category, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(category, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : null)), Text('$percentage%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percentage / 100, backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200, color: color, minHeight: 8)),
        ],
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String time;
  final int percentage;
  const _TimeSlot({required this.time, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(time, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percentage / 100, backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200, color: Theme.of(context).colorScheme.primary, minHeight: 8))),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text('$percentage%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : null))),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;
  const _LeaderboardItem({required this.rank, required this.name, required this.points, required this.isCurrentUser});

  Color _getRankColor() {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey.shade400;
      case 3: return Colors.brown.shade300;
      default: return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
          ? Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1) 
          : (isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) 
          : (isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _getRankColor(), shape: BoxShape.circle),
            child: Center(child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, color: rank <= 3 ? Colors.white : Colors.grey.shade700))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500, color: isDark ? Colors.white : null))),
          Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text('$points pts', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : null))]),
        ],
      ),
    );
  }
}
