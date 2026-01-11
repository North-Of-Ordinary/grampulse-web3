import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/report_models.dart';
import 'package:grampulse/features/report/presentation/bloc/describe_issue_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/describe_issue_event.dart';
import 'package:grampulse/features/report/presentation/bloc/describe_issue_state.dart';

class DescribeIssueScreen extends StatelessWidget {
  final List<ReportMedia> capturedMedia;
  final double latitude;
  final double longitude;
  final String address;

  const DescribeIssueScreen({
    Key? key,
    required this.capturedMedia,
    required this.latitude,
    required this.longitude,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DescribeIssueBloc(
        initialLatitude: latitude,
        initialLongitude: longitude,
        initialAddress: address,
      ),
      child: BlocConsumer<DescribeIssueBloc, DescribeIssueState>(
        listener: (context, state) {
          if (state is DescribeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Describe the Issue'),
                  Text(
                    'Step 2/4: Add Details',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: 0.5, // 2/4 steps
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            body: state is DescribeInitial || state is DescribeUpdating
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, state as DescribeReady),
            bottomNavigationBar: state is DescribeReady
                ? _buildBottomBar(context, state)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DescribeReady state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category selector
          _buildCategorySelector(context, state),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Description field
          Text(
            'Description',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Describe the issue in detail...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: state.isProcessingVoice
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {
                        context.read<DescribeIssueBloc>().add(
                          const ConvertVoiceToText(
                            audioFilePath: '', // No actual file in this mock
                          ),
                        );
                      },
                    ),
            ),
            onChanged: (value) {
              context.read<DescribeIssueBloc>().add(UpdateDescription(value));
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Severity selector
          _buildSeveritySelector(context, state),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Location confirmation
          Text(
            'Location',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  child: Text('Edit'),
                  onPressed: () {
                    // In a real app, show map to adjust location
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Location editing not implemented in this demo')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, DescribeReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issue Category',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: state.categories.map((category) {
              final isSelected = category.id == state.selectedCategoryId;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconData(
                          int.parse(category.iconCode),
                          fontFamily: 'MaterialIcons',
                        ),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(category.name),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<DescribeIssueBloc>().add(UpdateCategory(category.id));
                    }
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector(BuildContext context, DescribeReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issue Severity',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(
              value: 1,
              label: Text('Low'),
              icon: Icon(Icons.arrow_downward),
            ),
            ButtonSegment<int>(
              value: 2,
              label: Text('Medium'),
              icon: Icon(Icons.remove),
            ),
            ButtonSegment<int>(
              value: 3,
              label: Text('High'),
              icon: Icon(Icons.arrow_upward),
            ),
          ],
          selected: {state.severity},
          onSelectionChanged: (Set<int> selection) {
            context.read<DescribeIssueBloc>().add(UpdateSeverity(selection.first));
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  if (state.severity == 1) return Colors.green;
                  if (state.severity == 2) return Colors.amber;
                  if (state.severity == 3) return Colors.red;
                }
                return Theme.of(context).colorScheme.surface;
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Theme.of(context).colorScheme.onSurface;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, DescribeReady state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: state.canProceed
                  ? () {
                      context.read<DescribeIssueBloc>().add(const ValidateAndProceed());
                      
                      // Check if disaster related to conditionally show relief screen
                      final nextStep = state.isDisasterCategory
                          ? '/report-issue/relief'
                          : '/report-issue/review';
                      
                      // Navigate to next step
                      context.go(nextStep, extra: {
                        'media': capturedMedia,
                        'category': state.selectedCategory,
                        'description': state.description,
                        'severity': state.severity,
                        'latitude': state.latitude,
                        'longitude': state.longitude,
                        'address': state.address,
                      });
                    }
                  : null,
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
