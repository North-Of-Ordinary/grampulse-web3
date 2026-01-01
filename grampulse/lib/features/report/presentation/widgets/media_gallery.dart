import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

class MediaGallery extends StatelessWidget {
  final List<ReportMedia> mediaItems;
  
  const MediaGallery({
    Key? key,
    required this.mediaItems,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Media',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: mediaItems.length,
            itemBuilder: (context, index) {
              final media = mediaItems[index];
              
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenMediaView(
                          mediaItems: mediaItems,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: _getMediaImage(media),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: media.fileType == MediaType.video
                        ? Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  ImageProvider _getMediaImage(ReportMedia media) {
    if (media.file != null) {
      return FileImage(media.file!);
    } else if (media.thumbnailUrl != null) {
      return NetworkImage(media.thumbnailUrl!);
    } else if (media.url != null) {
      return NetworkImage(media.url!);
    } else {
      return const AssetImage('assets/images/placeholder.png');
    }
  }
}

class FullScreenMediaView extends StatefulWidget {
  final List<ReportMedia> mediaItems;
  final int initialIndex;
  
  const FullScreenMediaView({
    Key? key,
    required this.mediaItems,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late PageController _pageController;
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.mediaItems.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.mediaItems.length,
        itemBuilder: (context, index) {
          final media = widget.mediaItems[index];
          
          if (media.fileType == MediaType.video) {
            // In a real app, we'd use a video player here
            return const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 80,
                color: Colors.white,
              ),
            );
          } else {
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Center(
                child: _buildMediaContent(media),
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildMediaContent(ReportMedia media) {
    if (media.file != null) {
      return Image.file(media.file!);
    } else if (media.url != null) {
      return Image.network(
        media.url!,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.white60,
          );
        },
      );
    } else {
      return const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.white60,
      );
    }
  }
}
