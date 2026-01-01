import 'package:flutter/material.dart';
import 'package:grampulse/core/constants/spacing.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:grampulse/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class IssueBottomSheet extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onViewDetails;
  final VoidCallback onNavigate;
  
  const IssueBottomSheet({
    Key? key,
    required this.issue,
    required this.onViewDetails,
    required this.onNavigate,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: Spacing.md),
          
          // Issue summary
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: issue.category.color.withOpacity(0.2),
                child: Icon(
                  IconData(
                    int.parse(issue.category.iconCode),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: issue.category.color,
                  size: 20,
                ),
              ),
              SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(issue.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(context, issue.status),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(issue.status),
                            ),
                          ),
                        ),
                        SizedBox(width: Spacing.sm),
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 2),
                        Text(
                          _getTimeAgo(issue.createdAt, context),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: Spacing.md),
          
          // Description preview
          Text(
            issue.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: Spacing.md),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: Text(context.l10n.navigate),
                  onPressed: onNavigate,
                ),
              ),
              SizedBox(width: Spacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: Text(context.l10n.viewDetails),
                  onPressed: onViewDetails,
                ),
              ),
            ],
          ),
        ],
      ),
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
  
  String _getStatusLabel(BuildContext context, String status) {
    switch (status) {
      case 'new':
        return context.l10n.pending;
      case 'in_progress':
        return context.l10n.inProgress;
      case 'resolved':
        return context.l10n.resolved;
      case 'rejected':
        return context.l10n.rejected;
      default:
        return status;
    }
  }
  
  String _getTimeAgo(DateTime dateTime, [BuildContext? context]) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (context != null) {
          return context.l10n.minutesAgo(difference.inMinutes);
        }
        return '${difference.inMinutes} mins ago';
      }
      if (context != null) {
        return context.l10n.hoursAgo(difference.inHours);
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      if (context != null) {
        return context.l10n.daysAgo(difference.inDays);
      }
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }
}
