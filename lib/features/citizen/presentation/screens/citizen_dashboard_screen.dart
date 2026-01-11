import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grampulse/core/services/location_service.dart';
import 'package:grampulse/features/citizen/domain/models/incident_models.dart';
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_bloc.dart';
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_event.dart';
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_state.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
      // Location loaded - incidents are already loading from initState
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncidentBloc()
        ..add(LoadStatistics())
        ..add(LoadMyIncidents())
        ..add(const LoadNearbyIncidents()), // Load all incidents immediately
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Citizen Dashboard'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                context.read<IncidentBloc>().add(RefreshIncidents());
                context.read<IncidentBloc>().add(const LoadNearbyIncidents());
                _getCurrentLocation();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<IncidentBloc, IncidentState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<IncidentBloc>().add(RefreshIncidents());
                context.read<IncidentBloc>().add(const LoadNearbyIncidents());
                await _getCurrentLocation();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    if (state is IncidentLoaded && state.statistics != null)
                      _buildStatisticsCards(state.statistics!),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Reports
                    if (state is IncidentLoaded)
                      _buildRecentReports(state.myIncidents),
                    
                    const SizedBox(height: 24),
                    
                    // Nearby Issues - now shows all incidents regardless of location
                    if (state is IncidentLoaded)
                      _buildNearbyIssues(state.nearbyIncidents),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/citizen/report');
          },
          icon: const Icon(Icons.add_box),
          label: const Text('Report Issue'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(IncidentStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'My Reports',
                value: '${stats.myIncidents}',
                icon: Icons.report,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'New Issues',
                value: '${stats.newIncidents}',
                icon: Icons.fiber_new,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'In Progress',
                value: '${stats.inProgress}',
                icon: Icons.work,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Resolved',
                value: '${stats.resolved}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Report Issue',
                subtitle: 'Submit a new complaint',
                icon: Icons.add_box,
                color: Colors.blue,
                onTap: () => context.push('/citizen/report'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'My Reports',
                subtitle: 'View your submissions',
                icon: Icons.list_alt,
                color: Colors.green,
                onTap: () => context.push('/citizen/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentReports(List<Incident> incidents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (incidents.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/citizen/reports'),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (incidents.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No reports yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start by reporting an issue in your area',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...incidents.take(3).map((incident) => _buildIncidentCard(incident)),
      ],
    );
  }

  Widget _buildNearbyIssues(List<Incident> incidents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Issues',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (incidents.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.location_searching,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No nearby issues',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your area is clear of reported issues',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...incidents.take(3).map((incident) => _buildIncidentCard(incident)),
      ],
    );
  }

  Widget _buildIncidentCard(Incident incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(incident.status).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(incident.status),
            color: _getStatusColor(incident.status),
            size: 20,
          ),
        ),
        title: Text(
          incident.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          incident.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          incident.statusText,
          style: TextStyle(
            color: _getStatusColor(incident.status),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'NEW':
        return Icons.fiber_new;
      case 'IN_PROGRESS':
        return Icons.work;
      case 'RESOLVED':
        return Icons.check_circle;
      case 'CLOSED':
        return Icons.archive;
      default:
        return Icons.help_outline;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
