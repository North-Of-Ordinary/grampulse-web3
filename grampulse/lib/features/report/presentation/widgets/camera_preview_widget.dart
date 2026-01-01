import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/spacing.dart';

class CameraPreviewWidget extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onCapture;
  final VoidCallback onFlashToggle;
  final VoidCallback onGalleryTap;
  
  const CameraPreviewWidget({
    Key? key,
    required this.isFlashOn,
    required this.onCapture,
    required this.onFlashToggle,
    required this.onGalleryTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simple camera preview placeholder
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text('Camera Preview', style: TextStyle(color: Colors.white)),
                  ),
                ),
                // Grid overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPainter(),
                  ),
                ),
                // Controls row at bottom
                Positioned(
                  bottom: AppSpacing.md,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFlashOn 
                              ? Icons.flash_on 
                              : Icons.flash_off,
                          color: Colors.white,
                        ),
                        onPressed: onFlashToggle,
                      ),
                      GestureDetector(
                        onTap: onCapture,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        onPressed: onGalleryTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;
    
    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
    
    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
