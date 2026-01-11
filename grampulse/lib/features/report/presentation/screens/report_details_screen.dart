import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/report_details_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/report_details_event.dart';
import 'package:grampulse/features/report/presentation/bloc/report_details_state.dart';
import 'package:grampulse/features/report/presentation/widgets/media_gallery.dart';
import 'package:grampulse/features/report/presentation/widgets/rating_dialog.dart';
import 'package:grampulse/features/report/presentation/widgets/status_banner.dart';
import 'package:grampulse/features/report/presentation/widgets/status_timeline.dart';

class ReportDetailsScreen extends StatelessWidget {
  final String reportId;
  final IssueModel? issue;
  
  const ReportDetailsScreen({
    Key? key,
    required this.reportId,
    this.issue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportDetailsBloc(initialIssue: issue)
        ..add(LoadReportDetails(reportId)),
      child: BlocConsumer<ReportDetailsBloc, ReportDetailsState>(
        listener: (context, state) {
          if (state is DetailsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is DetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Report Details'),
              actions: [
                if (state is DetailsLoaded)
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      context.read<ReportDetailsBloc>().add(const ShareReport());
                    },
                  ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReportDetailsState state) {
    if (state is DetailsInitial || state is DetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is DetailsLoaded) {
      return _buildDetailsContent(context, state);
    } else if (state is DetailsUpdating) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(state.message),
              ],
            ),
          ),
        ),
      );
    } else if (state is DetailsError) {
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
                    context.read<ReportDetailsBloc>().add(LoadReportDetails(reportId));
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return const SizedBox();
  }

  Widget _buildDetailsContent(BuildContext context, DetailsLoaded state) {
    final issue = state.issue;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportDetailsBloc>().add(const RefreshReportDetails());
        // Wait for the refresh to complete
        return Future.delayed(const Duration(seconds: 1));
      },
      child: Stack(
        children: [
          ListView(
            children: [
              // Status banner
              StatusBanner(status: issue.status),
              
              // Issue details card
              _buildIssueDetailsCard(context, issue),
              
              const SizedBox(height: AppSpacing.md),
              
              // Media gallery
              if (issue.media.isNotEmpty)
                MediaGallery(mediaItems: issue.media),
              
              const SizedBox(height: AppSpacing.md),
              
              // Status timeline
              if (issue.statusUpdates != null && issue.statusUpdates!.isNotEmpty)
                StatusTimeline(
                  updates: issue.statusUpdates!,
                  currentStatus: issue.status,
                ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Department information card
              if (issue.assignedDepartment != null)
                _buildDepartmentInfoCard(context, issue),
              
              // Action buttons section
              _buildActionButtonsSection(context, issue),
              
              // Extra space for bottom padding
              const SizedBox(height: 100),
            ],
          ),
          
          // Show loading overlay when submitting an action
          if (state.isSubmittingAction)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIssueDetailsCard(BuildContext context, IssueModel issue) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: issue.category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconData(
                            int.parse(issue.category.iconCode),
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 16,
                          color: issue.category.color,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          issue.category.name,
                          style: TextStyle(
                            color: issue.category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ID: ${issue.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Title
              Text(
                issue.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Description
              Text(
                issue.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Reported date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Reported on ${DateFormat('dd MMM yyyy, hh:mm a').format(issue.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      issue.address ?? 'Unknown location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Open map view
                  },
                  child: const Text('View on Map'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentInfoCard(BuildContext context, IssueModel issue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Department Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Department name
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Assigned to: ${issue.assignedDepartment}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Officer name (if available)
              if (issue.assignedOfficer != null)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Officer: ${issue.assignedOfficer}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              
              if (issue.assignedOfficer != null)
                const SizedBox(height: AppSpacing.sm),
              
              // Expected resolution date
              if (issue.expectedResolutionDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Expected resolution: ${DateFormat('dd MMM yyyy').format(issue.expectedResolutionDate!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              
              const SizedBox(height: AppSpacing.md),
              
              // SLA Timer
              if (issue.status != 'resolved' && issue.status != 'closed' && issue.expectedResolutionDate != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _getSLAColor(issue.expectedResolutionDate!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getSLAColor(issue.expectedResolutionDate!),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: _getSLAColor(issue.expectedResolutionDate!),
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _getSLAText(issue.expectedResolutionDate!),
                        style: TextStyle(
                          color: _getSLAColor(issue.expectedResolutionDate!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsSection(BuildContext context, IssueModel issue) {
    // No actions for closed issues
    if (issue.status == 'closed') {
      return const SizedBox();
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Actions based on status
          if (issue.status == 'resolved')
            _buildResolvedActionButtons(context, issue)
          else if (issue.status == 'in_progress')
            _buildInProgressActionButtons(context, issue)
          else if (issue.status == 'new')
            _buildPendingActionButtons(context, issue)
          else if (issue.status == 'rejected')
            _buildRejectedActionButtons(context, issue),
        ],
      ),
    );
  }

  Widget _buildResolvedActionButtons(BuildContext context, IssueModel issue) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reopen Issue'),
            onPressed: () {
              _showReopenDialog(context);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirm Resolution'),
            onPressed: () {
              _showRatingDialog(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressActionButtons(BuildContext context, IssueModel issue) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.update),
      label: const Text('Request Update'),
      onPressed: () {
        _showRequestUpdateDialog(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildPendingActionButtons(BuildContext context, IssueModel issue) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.cancel),
      label: const Text('Cancel Report'),
      onPressed: () {
        _showCancelReportDialog(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRejectedActionButtons(BuildContext context, IssueModel issue) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.feedback),
      label: const Text('Appeal Decision'),
      onPressed: () {
        // Navigate to appeal form
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        onSubmit: (rating, feedback) {
          context.read<ReportDetailsBloc>().add(
            ConfirmResolution(rating: rating, feedback: feedback),
          );
        },
      ),
    );
  }

  void _showReopenDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reopen Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for reopening this issue:'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<ReportDetailsBloc>().add(ReopenIssue(controller.text));
              }
            },
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
  }

  void _showRequestUpdateDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please specify what information you need:'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your request',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<ReportDetailsBloc>().add(RequestUpdate(controller.text));
              }
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  void _showCancelReportDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this report?'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Report'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<ReportDetailsBloc>().add(CancelReport(controller.text));
              }
            },
            child: const Text('Yes, Cancel Report'),
          ),
        ],
      ),
    );
  }

  Color _getSLAColor(DateTime expectedDate) {
    final now = DateTime.now();
    final difference = expectedDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red;
    } else if (difference <= 1) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getSLAText(DateTime expectedDate) {
    final now = DateTime.now();
    final difference = expectedDate.difference(now).inDays;
    
    if (difference < 0) {
      return '${difference.abs()} days overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }
}
