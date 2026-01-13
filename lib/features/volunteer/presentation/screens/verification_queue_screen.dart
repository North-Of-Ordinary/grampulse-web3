import 'package:flutter/material.dart';
import 'package:grampulse/core/services/supabase_service.dart';

enum Priority { high, medium, low }
enum VerificationStatus { pending, inProgress, completed, cancelled }

class VerificationRequestItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final Priority priority;
  final String category;
  final DateTime submittedAt;
  final String estimatedTime;
  final String distance;
  final String citizenName;
  final VerificationStatus status;

  VerificationRequestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.priority,
    required this.category,
    required this.submittedAt,
    required this.estimatedTime,
    required this.distance,
    required this.citizenName,
    required this.status,
  });

  factory VerificationRequestItem.fromSupabase(Map<String, dynamic> data) {
    VerificationStatus mapStatus(String? status) {
      switch (status) {
        case 'new':
        case 'submitted':
          return VerificationStatus.pending;
        case 'in_progress':
        case 'verified':
          return VerificationStatus.inProgress;
        case 'resolved':
        case 'closed':
          return VerificationStatus.completed;
        default:
          return VerificationStatus.pending;
      }
    }

    Priority mapPriority(int? severity) {
      switch (severity) {
        case 3:
          return Priority.high;
        case 2:
          return Priority.medium;
        default:
          return Priority.low;
      }
    }

    final categoryData = data['categories'] as Map<String, dynamic>?;
    final reporterData = data['reporter'] as Map<String, dynamic>?;

    return VerificationRequestItem(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String? ?? '',
      location: data['location_address'] as String? ?? data['address'] as String? ?? 'Unknown location',
      priority: mapPriority(data['severity'] as int?),
      category: categoryData?['name'] as String? ?? 'Other',
      submittedAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
      estimatedTime: '30 min',
      distance: '-- km',
      citizenName: reporterData?['full_name'] as String? ?? 'Citizen',
      status: mapStatus(data['status'] as String?),
    );
  }
}

class VerificationQueueScreen extends StatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  State<VerificationQueueScreen> createState() => _VerificationQueueScreenState();
}

class _VerificationQueueScreenState extends State<VerificationQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'priority';
  
  final SupabaseService _supabase = SupabaseService();
  List<VerificationRequestItem> allRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('[VerificationQueueScreen] Loading incidents from Supabase...');
      final incidents = await _supabase.getAllIncidents();
      
      setState(() {
        allRequests = incidents.map((inc) => VerificationRequestItem.fromSupabase(inc)).toList();
        _isLoading = false;
      });
      
      debugPrint('[VerificationQueueScreen] ✅ Loaded ${allRequests.length} requests');
    } catch (e) {
      debugPrint('[VerificationQueueScreen] ❌ Error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _supabase.updateIncidentStatus(id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
      _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
      );
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
        title: const Text('Verification Queue'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadRequests, child: const Text('Retry')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsList(_getFilteredRequests('all')),
                    _buildRequestsList(_getFilteredRequests('pending')),
                    _buildRequestsList(_getFilteredRequests('inProgress')),
                    _buildRequestsList(_getFilteredRequests('completed')),
                  ],
                ),
    );
  }

  List<VerificationRequestItem> _getFilteredRequests(String filter) {
    List<VerificationRequestItem> filtered = allRequests;
    
    switch (filter) {
      case 'pending':
        filtered = allRequests.where((r) => r.status == VerificationStatus.pending).toList();
        break;
      case 'inProgress':
        filtered = allRequests.where((r) => r.status == VerificationStatus.inProgress).toList();
        break;
      case 'completed':
        filtered = allRequests.where((r) => r.status == VerificationStatus.completed).toList();
        break;
    }

    switch (_sortBy) {
      case 'priority':
        filtered.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case 'time':
        filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        break;
    }
    
    return filtered;
  }

  Widget _buildRequestsList(List<VerificationRequestItem> requests) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (requests.isEmpty) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No requests found', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Pull down to refresh', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) => _VerificationCard(
          request: requests[index],
          onVerify: () => _showVerificationDialog(requests[index]),
          onUpdateStatus: _updateStatus,
        ),
      ),
    );
  }

  void _showVerificationDialog(VerificationRequestItem request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              Text(request.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
              const SizedBox(height: 8),
              _buildInfoChip(request.category, Icons.category),
              const SizedBox(height: 16),
              Text(request.description, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.location_on, label: 'Location', value: request.location),
              _DetailRow(icon: Icons.person, label: 'Reported by', value: request.citizenName),
              _DetailRow(icon: Icons.directions_walk, label: 'Distance', value: request.distance),
              _DetailRow(icon: Icons.timer, label: 'Est. Time', value: request.estimatedTime),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(request.id, 'in_progress');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              if (request.status == VerificationStatus.inProgress)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(request.id, 'verified');
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Verified'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isDark ? Colors.blue.shade900 : Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700), const SizedBox(width: 4), Text(label, style: TextStyle(color: isDark ? Colors.blue.shade300 : Colors.blue.shade700, fontSize: 12))],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Infrastructure', 'Water Supply', 'Public Safety', 'Sanitation', 'Drainage'].map((cat) => ListTile(title: Text(cat), onTap: () => Navigator.pop(context))).toList(),
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(title: const Text('Priority'), value: 'priority', groupValue: _sortBy, onChanged: (v) { setState(() => _sortBy = v!); Navigator.pop(context); }),
            RadioListTile<String>(title: const Text('Distance'), value: 'distance', groupValue: _sortBy, onChanged: (v) { setState(() => _sortBy = v!); Navigator.pop(context); }),
            RadioListTile<String>(title: const Text('Time'), value: 'time', groupValue: _sortBy, onChanged: (v) { setState(() => _sortBy = v!); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final VerificationRequestItem request;
  final VoidCallback onVerify;
  final Function(String, String) onUpdateStatus;

  const _VerificationCard({required this.request, required this.onVerify, required this.onUpdateStatus});

  Color _getPriorityColor() {
    switch (request.priority) {
      case Priority.high: return Colors.red;
      case Priority.medium: return Colors.orange;
      case Priority.low: return Colors.green;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case VerificationStatus.pending: return 'Pending';
      case VerificationStatus.inProgress: return 'In Progress';
      case VerificationStatus.completed: return 'Completed';
      case VerificationStatus.cancelled: return 'Cancelled';
    }
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(request.submittedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
      child: InkWell(
        onTap: onVerify,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _getPriorityColor().withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.assignment, color: _getPriorityColor(), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : null)),
                        const SizedBox(height: 2),
                        Text(request.category, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getPriorityColor().withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(request.priority.name.toUpperCase(), style: TextStyle(color: _getPriorityColor(), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(request.description, style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(child: Text(request.location, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  Text(request.distance, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(width: 12),
                  Text(_getTimeAgo(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: Text(_getStatusText(), style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                  ),
                  if (request.status == VerificationStatus.pending)
                    FilledButton.tonal(onPressed: onVerify, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)), child: const Text('Verify')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label:', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : null))),
        ],
      ),
    );
  }
}
