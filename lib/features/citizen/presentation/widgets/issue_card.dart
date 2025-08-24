import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:grampulse/core/theme/spacing.dart';

class IssueCard extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String status;
  final String location;
  final DateTime? date;
  final String? distance;
  final VoidCallback onTap;

  const IssueCard._({
    Key? key,
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.location,
    this.date,
    this.distance,
    required this.onTap,
  }) : super(key: key);

  // Factory constructor for nearby issues
  factory IssueCard.nearby({
    Key? key,
    required String id,
    required String title,
    required String category,
    required String status,
    required String location,
    required String distance,
    required VoidCallback onTap,
  }) {
    return IssueCard._(
      key: key,
      id: id,
      title: title,
      category: category,
      status: status,
      location: location,
      distance: distance,
      onTap: onTap,
    );
  }

  // Factory constructor for my issues
  factory IssueCard.my({
    Key? key,
    required String id,
    required String title,
    required String category,
    required String status,
    required String location,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return IssueCard._(
      key: key,
      id: id,
      title: title,
      category: category,
      status: status,
      location: location,
      date: date,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCategoryIcon(category),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildStatusIndicator(context, status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      location,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (date != null) ...[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(date!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (distance != null) ...[
                    Icon(
                      Icons.directions_walk,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      distance!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    
    // Map category to appropriate icon
    switch (category.toLowerCase()) {
      case 'roads':
        iconData = Icons.add_road;
        break;
      case 'water':
        iconData = Icons.water_drop;
        break;
      case 'power':
        iconData = Icons.power;
        break;
      case 'sanitation':
        iconData = Icons.cleaning_services;
        break;
      case 'safety':
        iconData = Icons.security;
        break;
      case 'public property':
        iconData = Icons.domain;
        break;
      case 'environment':
        iconData = Icons.nature_people;
        break;
      case 'infrastructure':
        iconData = Icons.location_city;
        break;
      default:
        iconData = Icons.category;
    }
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        iconData,
        size: 16,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'new':
        color = Colors.blue;
        label = 'New';
        break;
      case 'in_progress':
        color = Colors.amber;
        label = 'In Progress';
        break;
      case 'resolved':
        color = Colors.green;
        label = 'Resolved';
        break;
      case 'overdue':
        color = Colors.red;
        label = 'Overdue';
        break;
      case 'verified':
        color = Colors.purple;
        label = 'Verified';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
