import 'package:flutter/material.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

class MediaPreview extends StatelessWidget {
  final ReportMedia media;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool showRemoveButton;
  final VoidCallback? onRemove;
  
  const MediaPreview({
    super.key,
    required this.media,
    this.width = 120,
    this.height = 120,
    this.onTap,
    this.showRemoveButton = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: _buildMediaContent(),
            ),
          ),
          if (showRemoveButton && onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          if (media.isVideo)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (media.fileType == MediaType.image) {
      if (media.file != null) {
        return Image.file(
          media.file!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      } else if (media.url != null) {
        return Image.network(
          media.url!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      }
    } else if (media.fileType == MediaType.video) {
      return Stack(
        alignment: Alignment.center,
        children: [
          if (media.thumbnailFile != null)
            Image.file(
              media.thumbnailFile!,
              width: width,
              height: height,
              fit: BoxFit.cover,
            )
          else if (media.thumbnailUrl != null)
            Image.network(
              media.thumbnailUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: width,
              height: height,
              color: Colors.black54,
            ),
          const Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 40,
          ),
        ],
      );
    } else if (media.fileType == MediaType.document) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              media.name ?? 'Document',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    
    return const Center(child: Text('Unsupported media'));
  }
}
