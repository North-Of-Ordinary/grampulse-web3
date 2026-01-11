import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';
import 'package:grampulse/features/report/presentation/widgets/media_preview_updated.dart';

class MediaListPreview extends StatelessWidget {
  final List<ReportMedia> mediaList;
  final Function(String) onRemove;

  const MediaListPreview({
    Key? key,
    required this.mediaList,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: Colors.grey[600], size: 32),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'No media added',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          final media = mediaList[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: MediaPreview(
              media: media,
              width: 100,
              height: 100,
              showRemoveButton: true,
              onRemove: () => onRemove(media.id),
            ),
          );
        },
      ),
    );
  }
}
