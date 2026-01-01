import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import '../bloc/volunteer_dashboard_bloc.dart';
import '../widgets/stats_card.dart';
import '../widgets/verification_request_card.dart';

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VolunteerDashboardBloc()..add(const LoadDashboard()),
      child: const _VolunteerDashboardView(),
    );
  }
}

class _VolunteerDashboardView extends StatelessWidget {
  const _VolunteerDashboardView();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VolunteerDashboardBloc>().add(const RefreshDashboard());
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: BlocBuilder<VolunteerDashboardBloc, VolunteerDashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is DashboardError) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<VolunteerDashboardBloc>().add(const LoadDashboard()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<VolunteerDashboardBloc>().add(const RefreshDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
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
                          Text('Welcome, Volunteer!', style: TextStyle(color: isDark ? Colors.white : colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Help make your community better', style: TextStyle(color: isDark ? Colors.grey.shade400 : colorScheme.onPrimary.withOpacity(0.9), fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats cards
                    const Text('Your Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          StatsCard(title: 'Pending', value: state.stats.pendingVerifications.toString(), icon: Icons.pending_actions, color: Colors.orange),
                          const SizedBox(width: 12),
                          StatsCard(title: 'Verified Today', value: state.stats.verifiedToday.toString(), icon: Icons.verified, color: Colors.green),
                          const SizedBox(width: 12),
                          StatsCard(title: 'Response Rate', value: '${state.stats.responseRate.toInt()}%', icon: Icons.speed, color: Colors.blue),
                          const SizedBox(width: 12),
                          StatsCard(title: 'Reputation', value: state.stats.reputation.toString(), icon: Icons.star, color: Colors.amber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _QuickActionCard(title: 'Verify Issues', icon: Icons.verified_user, color: Colors.blue, onTap: () => context.go('/volunteer/verification-queue'))),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickActionCard(title: 'Help Citizens', icon: Icons.people, color: Colors.green, onTap: () => context.go('/volunteer/assist-citizen'))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Verification Queue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending Verifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(onPressed: () => context.go('/volunteer/verification-queue'), child: const Text('View All')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (state.verificationQueue.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade400),
                              const SizedBox(height: 8),
                              Text('All caught up!', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : null)),
                              Text('No pending verifications', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...state.verificationQueue.take(3).map((request) => 
                        VerificationRequestCard(
                          request: request,
                          onAccept: () {
                            context.read<VolunteerDashboardBloc>().add(AcceptVerification(request.id));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accepted: ${request.title}')));
                          },
                          onSkip: () => context.read<VolunteerDashboardBloc>().add(SkipVerification(request.id)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Nearby requests
                    const Text('Nearby Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (state.nearbyRequests.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                        ),
                        child: Center(child: Text('No nearby requests', style: TextStyle(color: isDark ? Colors.grey.shade400 : null))),
                      )
                    else
                      ...state.nearbyRequests.map((request) => VerificationRequestCard(request: request)),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1A1A1A) : null,
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : null), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
