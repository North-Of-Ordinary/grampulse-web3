import 'package:flutter/material.dart';
import 'package:grampulse/core/services/supabase_service.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _supabase = SupabaseService();
  List<_InboxItem> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch incidents from Supabase and convert to notifications
      final incidents = await _supabase.getAllIncidents();
      
      final notifications = incidents.map((inc) {
        final status = inc['status'] as String? ?? 'new';
        final priority = inc['severity'] as int? ?? 1;
        
        String type = 'update';
        if (priority >= 3 || status == 'new' || status == 'submitted') {
          type = 'alert';
        } else if (status == 'resolved') {
          type = 'message';
        }
        
        String title;
        if (status == 'new' || status == 'submitted') {
          title = 'New Issue Reported';
        } else if (status == 'in_progress') {
          title = 'Issue In Progress';
        } else if (status == 'resolved') {
          title = 'Issue Resolved';
        } else {
          title = 'Issue Update';
        }
        
        return _InboxItem(
          id: inc['id'] as String? ?? '',
          type: type,
          title: title,
          message: inc['title'] as String? ?? 'No description',
          time: DateTime.tryParse(inc['created_at'] as String? ?? '') ?? DateTime.now(),
          isRead: status == 'resolved' || status == 'closed',
          incidentId: inc['id'] as String? ?? '',
        );
      }).toList();
      
      // Sort by time, newest first
      notifications.sort((a, b) => b.time.compareTo(a.time));
      
      setState(() {
        _notifications = notifications.take(20).toList();
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

  List<_InboxItem> get _unreadItems => _notifications.where((n) => !n.isRead).toList();
  List<_InboxItem> get _alertItems => _notifications.where((n) => n.type == 'alert').toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Badge(
              label: Text('${_unreadItems.length}'),
              isLabelVisible: _unreadItems.isNotEmpty,
              child: const Icon(Icons.mark_email_read),
            ),
            onPressed: () {
              setState(() {
                for (var item in _notifications) {
                  item.isRead = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All marked as read')));
            },
            tooltip: 'Mark all read',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'All (${_notifications.length})'),
            Tab(text: 'Unread (${_unreadItems.length})'),
            Tab(text: 'Alerts (${_alertItems.length})'),
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
                      ElevatedButton(onPressed: _loadNotifications, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationList(_notifications),
                      _buildNotificationList(_unreadItems),
                      _buildNotificationList(_alertItems),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNotificationList(List<_InboxItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (items.isEmpty) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No notifications', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _NotificationCard(
        item: items[index],
        onTap: () {
          setState(() => items[index].isRead = true);
          _showNotificationDetail(items[index]);
        },
        onDismiss: () {
          setState(() => _notifications.removeWhere((n) => n.id == items[index].id));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Notification dismissed'), action: SnackBarAction(label: 'Undo', onPressed: () {})));
        },
      ),
    );
  }

  void _showNotificationDetail(_InboxItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            Row(
              children: [
                _getTypeIcon(item.type),
                const SizedBox(width: 12),
                Expanded(child: Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null))),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.message, style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(_formatTime(item.time), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (item.type == 'alert') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to issue...')));
                  }
                },
                child: Text(item.type == 'alert' ? 'View Issue' : 'Dismiss'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case 'alert':
        return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.warning_amber, color: isDark ? Colors.red.shade300 : Colors.red.shade600));
      case 'update':
        return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.update, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700));
      default:
        return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.message, color: isDark ? Colors.green.shade300 : Colors.green.shade600));
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

class _InboxItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final String incidentId;

  _InboxItem({required this.id, required this.type, required this.title, required this.message, required this.time, required this.isRead, required this.incidentId});
}

class _NotificationCard extends StatelessWidget {
  final _InboxItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({required this.item, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        color: isDark 
          ? (item.isRead ? const Color(0xFF1A1A1A) : const Color(0xFF242424))
          : (item.isRead ? null : Colors.grey.shade100),
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
            child: Row(
              children: [
                _buildTypeIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(item.title, style: TextStyle(fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 15))),
                          if (!item.isRead) Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.message, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(_formatTime(), style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor, iconColor;
    IconData icon;
    
    switch (item.type) {
      case 'alert':
        bgColor = isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade100;
        iconColor = isDark ? Colors.red.shade300 : Colors.red.shade600;
        icon = Icons.warning_amber;
        break;
      case 'update':
        bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
        iconColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        icon = Icons.update;
        break;
      default:
        bgColor = isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade100;
        iconColor = isDark ? Colors.green.shade300 : Colors.green.shade600;
        icon = Icons.message;
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  String _formatTime() {
    final diff = DateTime.now().difference(item.time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
