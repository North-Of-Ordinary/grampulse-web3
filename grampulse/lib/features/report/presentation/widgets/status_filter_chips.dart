import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/spacing.dart';

class StatusFilterChips extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;
  
  const StatusFilterChips({
    Key? key,
    required this.selectedStatus,
    required this.onStatusSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final statuses = [
      'all',
      'new',
      'in_progress',
      'resolved',
      'rejected',
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: statuses.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: selectedStatus == status,
              onSelected: (_) => onStatusSelected(status),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: _getStatusColor(status).withOpacity(0.2),
              labelStyle: TextStyle(
                color: selectedStatus == status
                    ? _getStatusColor(status)
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: selectedStatus == status
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selectedStatus == status
                      ? _getStatusColor(status)
                      : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'all':
        return 'All';
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
}
