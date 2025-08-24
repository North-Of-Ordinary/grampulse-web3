import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:grampulse/core/theme/spacing.dart';

/// A preview map widget that shows issues on a map with optional zoom controls
class MapPreviewWidget extends StatelessWidget {
  /// List of issue markers to display on the map
  final List<Marker> markers;
  
  /// Center position of the map
  final LatLng center;
  
  /// Initial zoom level
  final double zoom;
  
  /// Map height (defaults to 200)
  final double height;
  
  /// Whether to show zoom controls
  final bool showZoomControls;
  
  /// Callback when map is tapped
  final VoidCallback? onTap;
  
  /// Whether to allow map interactions (pan/zoom)
  final bool interactive;

  const MapPreviewWidget({
    Key? key,
    required this.markers,
    required this.center,
    this.zoom = 14.0,
    this.height = 200,
    this.showZoomControls = false,
    this.onTap,
    this.interactive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.mediumBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Map widget
          FlutterMap(
            options: MapOptions(
              center: center,
              zoom: zoom,
              interactiveFlags: interactive 
                  ? InteractiveFlag.all 
                  : InteractiveFlag.none,
              onTap: onTap != null 
                  ? (_, __) => onTap!()
                  : null,
            ),
            children: [
              // Base map tiles layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.grampulse.app',
                // Add offline support here later
              ),
              // Markers layer
              MarkerLayer(markers: markers),
            ],
          ),
          
          // Zoom controls
          if (showZoomControls && interactive)
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    onPressed: () {
                      // We would need to use a MapController to implement zoom functionality
                      // This will be implemented when we add the full map screen
                    },
                  ),
                  SizedBox(height: AppSpacing.xs),
                  _ZoomButton(
                    icon: Icons.remove,
                    onPressed: () {
                      // Zoom out functionality
                    },
                  ),
                ],
              ),
            ),
            
          // Expand button or overlay
          if (onTap != null)
            Positioned(
              right: AppSpacing.sm,
              top: AppSpacing.sm,
              child: Container(
                padding: AppSpacing.smallAllPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.smallBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fullscreen,
                  size: AppSpacing.iconSizeSmall,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Zoom button widget used in the map
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: AppSpacing.iconSizeSmall,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

/// Creates a marker for issues on the map
Marker createIssueMarker({
  required LatLng position,
  required String id,
  required BuildContext context,
  VoidCallback? onTap,
  Color? markerColor,
  double size = 36.0,
  Widget? icon,
}) {
  final color = markerColor ?? Theme.of(context).colorScheme.primary;
  
  return Marker(
    width: size,
    height: size,
    point: position,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: icon ?? Icon(
          Icons.report_problem,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    ),
  );
}
