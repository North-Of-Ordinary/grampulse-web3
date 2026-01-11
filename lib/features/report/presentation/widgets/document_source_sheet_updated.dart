import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grampulse/core/theme/spacing.dart';

class DocumentSourceSheet extends StatelessWidget {
  const DocumentSourceSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Document Source',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Options
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.photo_camera, color: Colors.white),
            ),
            title: const Text('Take Photo'),
            subtitle: const Text('Use camera to capture document'),
            onTap: () => _handleCameraSelection(context),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.photo_library, color: Colors.white),
            ),
            title: const Text('Choose from Gallery'),
            subtitle: const Text('Select existing photo'),
            onTap: () => _handleGallerySelection(context),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.folder, color: Colors.white),
            ),
            title: const Text('Browse Files'),
            subtitle: const Text('Select PDF or document file'),
            onTap: () => _handleFileSelection(context),
          ),
          
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _handleCameraSelection(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        // Return file to calling screen
        Navigator.of(context).pop(File(photo.path));
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGallerySelection(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        // Return file to calling screen
        Navigator.of(context).pop(File(image.path));
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleFileSelection(BuildContext context) async {
    // In a real app, you would use a file picker package here
    // This is a simplified version that just shows a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker would open here. Using image picker for demo.'),
      ),
    );
    
    // Fall back to gallery selection for demo purposes
    _handleGallerySelection(context);
  }
}
