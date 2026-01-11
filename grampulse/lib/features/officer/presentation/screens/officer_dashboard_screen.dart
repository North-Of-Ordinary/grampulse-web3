import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import '../bloc/officer_dashboard_bloc.dart';

class OfficerDashboardScreen extends StatelessWidget {
  const OfficerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OfficerDashboardBloc()..add(const LoadOfficerDashboard()),
      child: const _OfficerDashboardView(),
    );
  }
}

class _OfficerDashboardView extends StatelessWidget {
  const _OfficerDashboardView();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
              context.go('/entry-role-selection');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Dashboard'),
        backgroundColor: const Color(0xFF0D0D0D), // Pure dark header
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => context.read<OfficerDashboardBloc>().add(const RefreshOfficerDashboard())),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')))),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _showLogoutDialog(context), tooltip: 'Sign Out'),
        ],
      ),
      body: BlocBuilder<OfficerDashboardBloc, OfficerDashboardState>(
        builder: (context, state) {
          if (state is OfficerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is OfficerDashboardError) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => context.read<OfficerDashboardBloc>().add(const LoadOfficerDashboard()), child: const Text('Retry')),
                    ],
                  ),
                ),
              ),
            );
          }
          
          if (state is OfficerDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<OfficerDashboardBloc>().add(const RefreshOfficerDashboard()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.badge, color: isDark ? Colors.blue.shade400 : Colors.white, size: 32),
                                  const SizedBox(width: 12),
                                  Text('Welcome, Officer!', style: TextStyle(color: isDark ? Colors.white : colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Manage and resolve community issues', style: TextStyle(color: isDark ? Colors.grey.shade400 : colorScheme.onPrimary.withOpacity(0.9), fontSize: 16)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _StatCard(title: 'Total Assigned', value: '${state.stats.totalAssigned}', icon: Icons.assignment, color: Colors.blue),
                        _StatCard(title: 'Pending Review', value: '${state.stats.pendingReview}', icon: Icons.pending_actions, color: Colors.orange),
                        _StatCard(title: 'In Progress', value: '${state.stats.inProgress}', icon: Icons.autorenew, color: Colors.purple),
                        _StatCard(title: 'Resolved (Week)', value: '${state.stats.resolvedThisWeek}', icon: Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _QuickActionCard(title: 'View Inbox', icon: Icons.inbox, color: Colors.blue, onTap: () => context.go('/officer/inbox'))),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickActionCard(title: 'Work Orders', icon: Icons.work, color: Colors.green, onTap: () => context.go('/officer/work-orders'))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Pending Issues
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(onPressed: () => context.go('/officer/inbox'), child: const Text('View All')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (state.pendingIssues.isEmpty)
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                            ),
                            child: Center(child: Text('No pending issues', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
                          );
                        },
                      )
                    else
                      ...state.pendingIssues.take(3).map((issue) => _IssueCard(issue: issue)),
                    
                    const SizedBox(height: 24),
                    
                    // In Progress
                    const Text('In Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    if (state.inProgressIssues.isEmpty)
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                            ),
                            child: Center(child: Text('No issues in progress', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
                          );
                        },
                      )
                    else
                      ...state.inProgressIssues.map((issue) => _IssueCard(issue: issue, showAssignee: true)),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          }
          
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Issue issue;
  final bool showAssignee;

  const _IssueCard({required this.issue, this.showAssignee = false});

  Color _getPriorityColor() {
    switch (issue.priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(issue.reportedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showIssueDetails(context),
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
                    decoration: BoxDecoration(color: _getPriorityColor().withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.report_problem, color: _getPriorityColor(), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(issue.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(issue.category, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getPriorityColor().withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(issue.priority, style: TextStyle(color: _getPriorityColor(), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(issue.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(child: Text(issue.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  Text(_getTimeAgo(), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              if (showAssignee && issue.assignedTo != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('Assigned: ${issue.assignedTo}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showIssueDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getPriorityColor().withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(issue.priority, style: TextStyle(color: _getPriorityColor(), fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Text(issue.status, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(issue.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Text(issue.category, style: TextStyle(color: Colors.blue.shade700, fontSize: 12))),
              const SizedBox(height: 16),
              Text(issue.description, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
              const SizedBox(height: 24),
              _DetailRow(icon: Icons.location_on, label: 'Location', value: issue.location),
              _DetailRow(icon: Icons.person, label: 'Reported by', value: issue.reportedBy),
              _DetailRow(icon: Icons.access_time, label: 'Reported', value: _getTimeAgo()),
              if (issue.deadline != null) _DetailRow(icon: Icons.event, label: 'Deadline', value: '${issue.deadline!.day}/${issue.deadline!.month}/${issue.deadline!.year}'),
              if (issue.assignedTo != null) _DetailRow(icon: Icons.engineering, label: 'Assigned to', value: issue.assignedTo!),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (issue.status == 'Pending Review') ...[
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Reject'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue approved'))); }, child: const Text('Approve'))),
                  ] else ...[
                    Expanded(child: FilledButton.icon(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated'))); }, icon: const Icon(Icons.update), label: const Text('Update Status'))),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label:', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
