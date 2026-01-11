import 'package:flutter/material.dart';

class CitizenMyReportsScreen extends StatefulWidget {
  const CitizenMyReportsScreen({Key? key}) : super(key: key);

  @override
  State<CitizenMyReportsScreen> createState() => _CitizenMyReportsScreenState();
}

class _CitizenMyReportsScreenState extends State<CitizenMyReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(context, 'All'),
          _buildReportsList(context, 'Pending'),
          _buildReportsList(context, 'In Progress'),
          _buildReportsList(context, 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildReportsList(BuildContext context, String status) {
    // Demo data for different tabs
    final List<Map<String, dynamic>> reports = [
      if (status == 'All' || status == 'Pending')
        {
          'id': '1',
          'title': 'Garbage Collection Issue',
          'description': 'Garbage has not been collected for the past 3 days',
          'category': 'Sanitation',
          'status': 'Pending',
          'date': 'Aug 25, 2025',
          'statusColor': Colors.amber,
        },
      if (status == 'All' || status == 'In Progress')
        {
          'id': '2',
          'title': 'Broken Streetlight',
          'description': 'Streetlight at the corner of Main St. is not working',
          'category': 'Infrastructure',
          'status': 'In Progress',
          'date': 'Aug 20, 2025',
          'statusColor': Colors.orange,
        },
      if (status == 'All' || status == 'In Progress')
        {
          'id': '3',
          'title': 'Water Supply Interruption',
          'description': 'No water supply in the East Block since morning',
          'category': 'Utilities',
          'status': 'In Progress',
          'date': 'Aug 18, 2025',
          'statusColor': Colors.orange,
        },
      if (status == 'All' || status == 'Resolved')
        {
          'id': '4',
          'title': 'Pothole on Main Road',
          'description': 'Large pothole causing traffic problems',
          'category': 'Roads',
          'status': 'Resolved',
          'date': 'Aug 15, 2025',
          'statusColor': Colors.green,
        },
    ];

    if (reports.isEmpty) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No reports found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'You have no reports with status: $status',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildReportCard(
            context,
            id: report['id'],
            title: report['title'],
            description: report['description'],
            category: report['category'],
            status: report['status'],
            date: report['date'],
            statusColor: report['statusColor'],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String id,
    required String title,
    required String description,
    required String category,
    required String status,
    required String date,
    required Color statusColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to report details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          category,
                          style: TextStyle(
                            color: _getCategoryColor(category),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Reported on $date',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to report details
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sanitation':
        return Icons.delete;
      case 'Infrastructure':
        return Icons.build;
      case 'Utilities':
        return Icons.water_drop;
      case 'Roads':
        return Icons.directions_car;
      default:
        return Icons.report_problem;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sanitation':
        return Colors.green;
      case 'Infrastructure':
        return Colors.blue;
      case 'Utilities':
        return Colors.purple;
      case 'Roads':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
