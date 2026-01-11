import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/components/buttons/app_button.dart';
import 'package:grampulse/core/components/containers/section_container.dart';
import 'package:grampulse/core/theme/app_text_styles.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/submit_issue_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/submit_issue_event.dart';
import 'package:grampulse/features/report/presentation/bloc/submit_issue_state.dart';
import 'package:grampulse/features/report/presentation/widgets/media_preview_updated.dart';

class ReviewSubmitScreen extends StatelessWidget {
  final List<ReportMedia> media;
  final CategoryModel category;
  final String description;
  final int severity;
  final double latitude;
  final double longitude;
  final String address;
  final ReliefRequest? reliefRequest;

  const ReviewSubmitScreen({
    super.key,
    required this.media,
    required this.category,
    required this.description,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.reliefRequest,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubmitIssueBloc(
        media: media,
        category: category,
        description: description,
        severity: severity,
        latitude: latitude,
        longitude: longitude,
        address: address,
        reliefRequest: reliefRequest,
      ),
      child: BlocConsumer<SubmitIssueBloc, SubmitIssueState>(
        listener: (context, state) {
          if (state is SubmitSuccess) {
            // Show success dialog and navigate back to home
            _showSuccessDialog(context, state.issueId);
          } else if (state is SubmitOfflineQueued) {
            // Show queued dialog and navigate back to home
            _showOfflineQueuedDialog(context, state.queuedId);
          } else if (state is SubmitError) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Review & Submit'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: state is SubmitReady
                ? _buildReviewContent(context, state)
                : _buildStatusContent(context, state),
            bottomNavigationBar: state is SubmitReady 
                ? _buildBottomBar(context, state) 
                : null,
          );
        },
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, SubmitReady state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaSection(context, state),
          const SizedBox(height: 16),
          _buildLocationSection(context, state),
          const SizedBox(height: 16),
          _buildCategorySection(context, state),
          const SizedBox(height: 16),
          _buildDescriptionSection(context, state),
          const SizedBox(height: 16),
          if (state.reliefRequest != null) _buildReliefSection(context, state),
          const SizedBox(height: 32),
          if (!state.isOnline) _buildOfflineWarning(context),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, SubmitReady state) {
    return SectionContainer(
      title: 'Media',
      actionLabel: 'Edit',
      onActionTap: () => context.read<SubmitIssueBloc>().add(
            const EditSection(sectionType: SectionType.media),
          ),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: state.media.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: MediaPreview(
                media: state.media[index],
                width: 120,
                height: 120,
                onTap: null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, SubmitReady state) {
    return SectionContainer(
      title: 'Location',
      actionLabel: 'Edit',
      onActionTap: () => context.read<SubmitIssueBloc>().add(
            const EditSection(sectionType: SectionType.location),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.address,
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Coordinates: ${state.latitude.toStringAsFixed(6)}, ${state.longitude.toStringAsFixed(6)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, SubmitReady state) {
    return SectionContainer(
      title: 'Category & Severity',
      actionLabel: 'Edit',
      onActionTap: () => context.read<SubmitIssueBloc>().add(
            const EditSection(sectionType: SectionType.category),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(state.category.name),
            backgroundColor: state.category.color.withOpacity(0.2),
            side: BorderSide(color: state.category.color),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Severity: ', style: AppTextStyles.bodyBold),
              Text(
                _severityLabel(state.severity),
                style: TextStyle(
                  color: _severityColor(state.severity),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, SubmitReady state) {
    return SectionContainer(
      title: 'Description',
      actionLabel: 'Edit',
      onActionTap: () => context.read<SubmitIssueBloc>().add(
            const EditSection(sectionType: SectionType.description),
          ),
      child: Text(
        state.description,
        style: AppTextStyles.body,
      ),
    );
  }

  Widget _buildReliefSection(BuildContext context, SubmitReady state) {
    final reliefRequest = state.reliefRequest!;
    return SectionContainer(
      title: 'Relief Request',
      actionLabel: 'Edit',
      onActionTap: () => context.read<SubmitIssueBloc>().add(
            const EditSection(sectionType: SectionType.relief),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Damage Value: ₹${reliefRequest.damageValue}', style: AppTextStyles.body),
          const SizedBox(height: 4),
          Text(
            'Bank: ${reliefRequest.bankDetails.accountHolder} (${reliefRequest.bankDetails.bankName})',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 4),
          Text(
            'Account: ${reliefRequest.bankDetails.accountNumber}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 8),
          if (reliefRequest.documents.isNotEmpty)
            Text('${reliefRequest.documents.length} document(s) attached',
                style: AppTextStyles.bodyBold),
        ],
      ),
    );
  }

  Widget _buildOfflineWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Text('You are offline', style: AppTextStyles.subtitleBold),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your issue will be queued and submitted automatically when you go online.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, SubmitIssueState state) {
    if (state is SubmitValidating) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text('Validating issue details...'),
              ],
            ),
          ),
        ),
      );
    } else if (state is SubmitUploading) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: state.progress / state.total,
                ),
                const SizedBox(height: 24),
                Text('Uploading media (${state.progress}%)...'),
              ],
            ),
          ),
        ),
      );
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBottomBar(BuildContext context, SubmitReady state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Cancel',
                type: AppButtonType.outline,
                onPressed: () => context.read<SubmitIssueBloc>().add(const CancelSubmission()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                label: state.isOnline ? 'Submit Issue' : 'Save for Later',
                type: AppButtonType.primary,
                onPressed: () => context.read<SubmitIssueBloc>().add(const SubmitIssue()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _severityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  Color _severityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green.shade700;
      case 2:
        return Colors.orange.shade700;
      case 3:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  void _showSuccessDialog(BuildContext context, String issueId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Issue Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text('Your issue has been successfully submitted.'),
            const SizedBox(height: 8),
            Text('Issue ID: $issueId', style: AppTextStyles.caption),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and navigate back to home
              Navigator.of(context).pop();
              context.go('/citizen');
            },
            child: const Text('View My Issues'),
          ),
          TextButton(
            onPressed: () {
              // Close dialog and navigate back to home
              Navigator.of(context).pop();
              context.go('/citizen');
            },
            child: const Text('Go Home'),
          ),
        ],
      ),
    );
  }

  void _showOfflineQueuedDialog(BuildContext context, String queuedId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Saved for Later'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.schedule, color: Colors.amber.shade700, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Your issue has been saved and will be submitted automatically when you go online.',
            ),
            const SizedBox(height: 8),
            Text('Queue ID: $queuedId', style: AppTextStyles.caption),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and navigate back to home
              Navigator.of(context).pop();
              context.go('/citizen');
            },
            child: const Text('Go Home'),
          ),
        ],
      ),
    );
  }
}
