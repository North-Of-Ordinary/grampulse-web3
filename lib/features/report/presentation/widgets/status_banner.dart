import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/spacing.dart';

class StatusBanner extends StatelessWidget {
  final String status;
  
  const StatusBanner({
    Key? key,
    required this.status,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: _getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _getStatusLabel(status),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
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
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'new':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.engineering;
      case 'resolved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'new':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
