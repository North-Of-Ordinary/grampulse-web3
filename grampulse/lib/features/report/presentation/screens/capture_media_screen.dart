import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/app_theme.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/presentation/bloc/capture_media_bloc.dart';
import 'package:grampulse/features/report/presentation/bloc/capture_media_event.dart';
import 'package:grampulse/features/report/presentation/bloc/capture_media_state.dart';
import 'package:grampulse/features/report/presentation/widgets/camera_preview_widget.dart';
import 'package:grampulse/features/report/presentation/widgets/media_list_preview.dart';
import 'package:grampulse/l10n/l10n.dart';

class CaptureMediaScreen extends StatelessWidget {
  const CaptureMediaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CaptureMediaBloc()..add(const InitializeCamera()),
      child: BlocConsumer<CaptureMediaBloc, CaptureMediaState>(
        listener: (context, state) {
          if (state is CaptureError) {
            // Show error snackbar
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
                  Text('Report an Issue'),
                  Text(
                    'Step 1/4: Capture Media',
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
                        '1',
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
                  value: 0.25, // 1/4 steps
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            body: state is CaptureInitial || state is CaptureLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, state),
            bottomNavigationBar: state is CaptureReady
                ? _buildBottomBar(context, state)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CaptureMediaState state) {
    if (state is CaptureReady) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera preview
            CameraPreviewWidget(
              isFlashOn: state.isFlashOn,
              onCapture: () => context.read<CaptureMediaBloc>().add(const CaptureImage()),
              onFlashToggle: () => context.read<CaptureMediaBloc>().add(const ToggleFlash()),
              onGalleryTap: () => context.read<CaptureMediaBloc>().add(const SelectFromGallery()),
            ),
            
            // Media preview section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Media (${state.capturedMedia.length}/4)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (state.capturedMedia.isNotEmpty)
                        Text(
                          'Tap to remove',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  MediaListPreview(
                    mediaList: state.capturedMedia,
                    onRemove: (id) => context.read<CaptureMediaBloc>().add(RemoveMedia(mediaId: id)),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Voice recording button
                  InkWell(
                    onTap: () {
                      if (state.isRecording) {
                        context.read<CaptureMediaBloc>().add(const StopVoiceRecording());
                      } else {
                        context.read<CaptureMediaBloc>().add(const StartVoiceRecording());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: state.isRecording
                            ? Colors.red.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.isRecording ? Icons.stop : Icons.mic,
                            color: state.isRecording
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            state.isRecording
                                ? 'Stop Recording'
                                : 'Record Voice Description',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: state.isRecording
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          if (state.isRecording)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Location display
                  InkWell(
                    onTap: () => context.read<CaptureMediaBloc>().add(const RefreshLocation()),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: state.locationError != null
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: state.locationAddress != null
                                ? Text(
                                    state.locationAddress!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : state.locationError != null
                                    ? Text(
                                        state.locationError!,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Text('Getting location...'),
                          ),
                          Icon(Icons.refresh),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Center(child: Text('Something went wrong'));
  }

  Widget _buildBottomBar(BuildContext context, CaptureReady state) {
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
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Discard Report?'),
                    content: Text('Are you sure you want to discard this report?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<CaptureMediaBloc>().add(const DisposeCamera());
                          context.go('/');
                        },
                        child: Text('Discard'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: state.canProceed
                  ? () {
                      context.read<CaptureMediaBloc>().add(const ValidateAndProceed());
                      // Navigate to next step
                      context.go('/report-issue/describe', extra: {
                        'media': state.capturedMedia,
                        'latitude': state.latitude,
                        'longitude': state.longitude,
                        'address': state.locationAddress,
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
