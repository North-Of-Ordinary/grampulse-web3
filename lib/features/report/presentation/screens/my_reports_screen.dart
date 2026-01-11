import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_event.dart';
import 'package:grampulse/features/report/presentation/bloc/my_reports_state.dart';
import 'package:grampulse/features/report/presentation/widgets/report_card.dart';
import 'package:grampulse/features/report/presentation/widgets/status_filter_chips.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyReportsBloc()..add(const LoadMyReports()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showSortingOptions(context);
              },
            ),
          ],
        ),
        body: BlocBuilder<MyReportsBloc, MyReportsState>(
          builder: (context, state) {
            if (state is ReportsInitial || state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReportsEmpty) {
              return _buildEmptyState(context);
            } else if (state is ReportsLoaded) {
              return _buildReportsList(context, state);
            } else if (state is ReportsError) {
              return _buildErrorState(context, state);
            }
            
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.go('/report-issue');
          },
          icon: const Icon(Icons.add),
          label: const Text('Report Issue'),
        ),
      ),
    );
  }

  Widget _buildReportsList(BuildContext context, ReportsLoaded state) {
    return Column(
      children: [
        // Status filter chips
        StatusFilterChips(
          selectedStatus: state.selectedStatus,
          onStatusSelected: (status) {
            context.read<MyReportsBloc>().add(FilterByStatus(status));
          },
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Reports list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<MyReportsBloc>().add(const RefreshReports());
              // Wait for the refresh to complete
              return Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: state.reports.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Load more when reaching the end
                if (index >= state.reports.length) {
                  context.read<MyReportsBloc>().add(const LoadMoreReports());
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                
                // Render report card
                final report = state.reports[index] as IssueModel;
                return ReportCard(
                  issue: report,
                  onTap: () {
                    context.go('/report-details/${report.id}', extra: report);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/no_reports.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No reports yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start by creating your first issue report',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/report-issue');
                },
                icon: const Icon(Icons.add),
                label: const Text('Report New Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ReportsError state) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  context.read<MyReportsBloc>().add(const LoadMyReports(refresh: true));
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Date (Newest First)'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  Navigator.pop(context);
                  // Sort logic would be implemented here
                },
              ),
              ListTile(
                title: const Text('Sort by Date (Oldest First)'),
                leading: const Icon(Icons.calendar_today_outlined),
                onTap: () {
                  Navigator.pop(context);
                  // Sort logic would be implemented here
                },
              ),
              ListTile(
                title: const Text('Sort by Status'),
                leading: const Icon(Icons.sort),
                onTap: () {
                  Navigator.pop(context);
                  // Sort logic would be implemented here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
