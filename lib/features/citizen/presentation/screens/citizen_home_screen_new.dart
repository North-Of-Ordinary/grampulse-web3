import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/domain/auth_events_states.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';

class CitizenHomeScreenNew extends StatefulWidget {
  const CitizenHomeScreenNew({Key? key}) : super(key: key);

  @override
  State<CitizenHomeScreenNew> createState() => _CitizenHomeScreenNewState();
}

class _CitizenHomeScreenNewState extends State<CitizenHomeScreenNew> {
  final ApiService _apiService = ApiService();
  List<dynamic> _categories = [];
  List<dynamic> _myIncidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load categories
      final categoriesResponse = await _apiService.getCategories();
      if (categoriesResponse.success) {
        _categories = categoriesResponse.data ?? [];
      }

      // Load my incidents
      final incidentsResponse = await _apiService.getMyIncidents();
      if (incidentsResponse.success) {
        _myIncidents = incidentsResponse.data ?? [];
      }
    } catch (e) {
      print('Error loading data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GramPulse - Citizen'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnauthenticatedState) {
            context.go('/auth');
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to GramPulse!',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Report issues, track progress, and help improve your community.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.add_circle,
                                label: 'Report Issue',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Report feature coming soon!')),
                                  );
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.map,
                                label: 'View Map',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Map feature coming soon!')),
                                  );
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.history,
                                label: 'My Reports',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('You have ${_myIncidents.length} reports')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Categories Section
                      Text(
                        'Issue Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _categories.isEmpty
                              ? const Text('No categories available')
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Available Categories: ${_categories.length}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: _categories.map((category) {
                                        return Chip(
                                          label: Text(category['name'] ?? 'Unknown'),
                                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // My Incidents Section
                      Text(
                        'My Reports',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _myIncidents.isEmpty
                              ? const Column(
                                  children: [
                                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('No reports yet'),
                                    Text(
                                      'Start by reporting your first issue!',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Reports: ${_myIncidents.length}'),
                                    const SizedBox(height: 8),
                                    ..._myIncidents.map((incident) {
                                      return ListTile(
                                        title: Text(incident['title'] ?? 'No title'),
                                        subtitle: Text(incident['status'] ?? 'Unknown status'),
                                        trailing: Chip(
                                          label: Text(incident['priority'] ?? 'medium'),
                                          backgroundColor: _getPriorityColor(incident['priority']),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // API Status
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Status',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text('Connected to backend: ${ApiService.baseUrl}'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.security, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text('JWT Authentication: Active'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red.withOpacity(0.2);
      case 'medium':
        return Colors.orange.withOpacity(0.2);
      case 'low':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
