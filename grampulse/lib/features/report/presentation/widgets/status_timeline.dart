import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusUpdate> updates;
  final String currentStatus;
  
  const StatusTimeline({
    Key? key,
    required this.updates,
    required this.currentStatus,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Status Timeline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            final update = updates[index];
            final isLast = index == updates.length - 1;
            final isActive = update.status == currentStatus;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive 
                              ? _getStatusColor(update.status) 
                              : Colors.grey.shade300,
                          border: Border.all(
                            color: isActive 
                                ? _getStatusColor(update.status) 
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusLabel(update.status),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive 
                              ? _getStatusColor(update.status) 
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _getFormattedDateTime(update.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (update.details != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          update.details!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      SizedBox(height: isLast ? 0 : AppSpacing.md),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'new':
        return 'Reported';
      case 'verified':
        return 'Verified';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
  
  String _getFormattedDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}
