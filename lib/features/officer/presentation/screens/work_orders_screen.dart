import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/officer_dashboard_bloc.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _sortBy = 'Date';

  final List<_WorkOrder> _workOrders = [
    _WorkOrder(id: 'WO001', title: 'Road Repair - Main Street', description: 'Potholes near market area causing traffic issues', category: 'Infrastructure', priority: 'High', status: 'In Progress', location: 'Main Street, Sector 3', assignedTo: 'Contractor A', createdAt: DateTime.now().subtract(const Duration(days: 2)), deadline: DateTime.now().add(const Duration(days: 5))),
    _WorkOrder(id: 'WO002', title: 'Street Light Installation', description: 'Install 10 new LED street lights in residential area', category: 'Electrical', priority: 'Medium', status: 'Pending', location: 'Block B, Housing Colony', assignedTo: null, createdAt: DateTime.now().subtract(const Duration(days: 1)), deadline: DateTime.now().add(const Duration(days: 7))),
    _WorkOrder(id: 'WO003', title: 'Water Pipeline Leak', description: 'Major water leak causing water shortage in Ward 5', category: 'Water Supply', priority: 'High', status: 'In Progress', location: 'Ward 5, Near School', assignedTo: 'Water Dept', createdAt: DateTime.now().subtract(const Duration(hours: 12)), deadline: DateTime.now().add(const Duration(days: 1))),
    _WorkOrder(id: 'WO004', title: 'Drainage Cleaning', description: 'Blocked drainage causing waterlogging during rains', category: 'Sanitation', priority: 'Medium', status: 'Pending', location: 'Market Area', assignedTo: null, createdAt: DateTime.now().subtract(const Duration(days: 3)), deadline: DateTime.now().add(const Duration(days: 10))),
    _WorkOrder(id: 'WO005', title: 'Park Maintenance', description: 'Routine maintenance of community park', category: 'Public Spaces', priority: 'Low', status: 'Completed', location: 'Central Park', assignedTo: 'Garden Dept', createdAt: DateTime.now().subtract(const Duration(days: 7)), deadline: DateTime.now().subtract(const Duration(days: 1))),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_WorkOrder> _getFilteredOrders(String status) {
    var orders = status == 'All' ? _workOrders : _workOrders.where((o) => o.status == status).toList();
    if (_selectedFilter != 'All') {
      orders = orders.where((o) => o.priority == _selectedFilter).toList();
    }
    switch (_sortBy) {
      case 'Priority':
        orders.sort((a, b) => _priorityValue(b.priority).compareTo(_priorityValue(a.priority)));
        break;
      case 'Deadline':
        orders.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      default:
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return orders;
  }

  int _priorityValue(String priority) {
    switch (priority) {
      case 'High': return 3;
      case 'Medium': return 2;
      default: return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Orders'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by Priority',
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => ['All', 'High', 'Medium', 'Low'].map((p) => PopupMenuItem(value: p, child: Row(children: [if (_selectedFilter == p) const Icon(Icons.check, size: 18), const SizedBox(width: 8), Text(p)]))).toList(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => ['Date', 'Priority', 'Deadline'].map((s) => PopupMenuItem(value: s, child: Row(children: [if (_sortBy == s) const Icon(Icons.check, size: 18), const SizedBox(width: 8), Text(s)]))).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'All (${_workOrders.length})'),
            Tab(text: 'Pending (${_workOrders.where((o) => o.status == 'Pending').length})'),
            Tab(text: 'In Progress (${_workOrders.where((o) => o.status == 'In Progress').length})'),
            Tab(text: 'Done (${_workOrders.where((o) => o.status == 'Completed').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_getFilteredOrders('All')),
          _buildOrderList(_getFilteredOrders('Pending')),
          _buildOrderList(_getFilteredOrders('In Progress')),
          _buildOrderList(_getFilteredOrders('Completed')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWorkOrderDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildOrderList(List<_WorkOrder> orders) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (orders.isEmpty) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off_outlined, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No work orders found', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _WorkOrderCard(
        order: orders[index],
        onTap: () => _showOrderDetails(orders[index]),
        onStatusChange: (status) => setState(() => orders[index].status = status),
      ),
    );
  }

  void _showOrderDetails(_WorkOrder order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              Row(
                children: [
                  Text(order.id, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(order.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PriorityChip(priority: order.priority),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(order.category, style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 16),
              Text(order.description, style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
              const SizedBox(height: 24),
              _DetailRow(icon: Icons.location_on, label: 'Location', value: order.location),
              _DetailRow(icon: Icons.calendar_today, label: 'Created', value: '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
              _DetailRow(icon: Icons.event, label: 'Deadline', value: '${order.deadline.day}/${order.deadline.month}/${order.deadline.year}'),
              if (order.assignedTo != null) _DetailRow(icon: Icons.engineering, label: 'Assigned to', value: order.assignedTo!),
              const SizedBox(height: 24),
              const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Pending', 'In Progress', 'Completed'].map((status) => ChoiceChip(
                  label: Text(status),
                  selected: order.status == status,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => order.status = status);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
                    }
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),
              if (order.assignedTo == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAssignDialog(order);
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Assign Contractor'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDialog(_WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Work Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select contractor for: ${order.title}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ...['Contractor A', 'Contractor B', 'Water Dept', 'Garden Dept', 'Electrical Dept'].map((c) => ListTile(
              title: Text(c),
              leading: const Icon(Icons.business),
              onTap: () {
                setState(() => order.assignedTo = c);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned to $c')));
              },
            )),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  void _showCreateWorkOrderDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Infrastructure';
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Work Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: ['Infrastructure', 'Electrical', 'Water Supply', 'Sanitation', 'Public Spaces'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: ['High', 'Medium', 'Low'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setDialogState(() => selectedPriority = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _workOrders.insert(0, _WorkOrder(
                      id: 'WO00${_workOrders.length + 1}',
                      title: titleController.text,
                      description: descController.text,
                      category: selectedCategory,
                      priority: selectedPriority,
                      status: 'Pending',
                      location: 'TBD',
                      assignedTo: null,
                      createdAt: DateTime.now(),
                      deadline: DateTime.now().add(const Duration(days: 7)),
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work order created')));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkOrder {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  String status;
  final String location;
  String? assignedTo;
  final DateTime createdAt;
  final DateTime deadline;

  _WorkOrder({required this.id, required this.title, required this.description, required this.category, required this.priority, required this.status, required this.location, this.assignedTo, required this.createdAt, required this.deadline});
}

class _WorkOrderCard extends StatelessWidget {
  final _WorkOrder order;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const _WorkOrderCard({required this.order, required this.onTap, required this.onStatusChange});

  Color _getPriorityColor() {
    switch (order.priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = order.deadline.isBefore(DateTime.now()) && order.status != 'Completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1A1A1A) : null,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue 
          ? BorderSide(color: Colors.red.shade300, width: 2) 
          : (isDark ? const BorderSide(color: Color(0xFF2D2D2D)) : BorderSide.none),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.id, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : null)),
              const SizedBox(height: 4),
              Text(order.description, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PriorityChip(priority: order.priority),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(child: Text(order.location, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: isOverdue ? Colors.red : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  const SizedBox(width: 4),
                  Text('Due: ${order.deadline.day}/${order.deadline.month}', style: TextStyle(color: isOverdue ? Colors.red : (isDark ? Colors.grey.shade400 : Colors.grey.shade600), fontSize: 12, fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal)),
                  if (order.assignedTo != null) ...[
                    const Spacer(),
                    Icon(Icons.person_outline, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(order.assignedTo!, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Completed': color = Colors.green; break;
      case 'In Progress': color = Colors.grey; break; // Changed from blue to grey
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case 'High': color = Colors.red; break;
      case 'Medium': color = Colors.orange; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(priority, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
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
