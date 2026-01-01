import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/report_models.dart';

class MediaPreview extends StatelessWidget {
  final List<ReportMedia> mediaList;
  final Function(String) onRemove;

  const MediaPreview({
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
          color: Colors.grey[200],
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
                'Capture or select media',
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
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    image: media.isImage
                        ? DecorationImage(
                            image: FileImage(media.file),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !media.isImage
                      ? Center(
                          child: Icon(
                            media.isVideo ? Icons.videocam : Icons.mic,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove(media.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
