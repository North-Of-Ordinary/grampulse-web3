import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:grampulse/core/theme/app_theme.dart';
import 'package:grampulse/core/theme/spacing.dart';

class MapPreview extends StatelessWidget {
  final LatLng center;
  final List<Map<String, dynamic>> issues;
  final double radius;
  final VoidCallback onTap;

  const MapPreview({
    Key? key,
    required this.center,
    required this.issues,
    required this.radius,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: center,
                  zoom: 14.0,
                  interactiveFlags: InteractiveFlag.none,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: center,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderColor: Theme.of(context).colorScheme.primary,
                        borderStrokeWidth: 2,
                        radius: radius * 1000, // Convert km to meters
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Icon(
                            Icons.person_pin_circle,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      ...issues.map((issue) {
                        return Marker(
                          point: issue['coordinates'],
                          width: 30,
                          height: 30,
                          child: _buildMarkerIcon(context, issue['status']),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fullscreen,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View Full Map',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerIcon(BuildContext context, String status) {
    Color markerColor;
    IconData markerIcon;

    switch (status) {
      case 'new':
        markerColor = Colors.blue;
        markerIcon = Icons.fiber_new;
        break;
      case 'in_progress':
        markerColor = Colors.amber;
        markerIcon = Icons.engineering;
        break;
      case 'resolved':
        markerColor = Colors.green;
        markerIcon = Icons.check_circle;
        break;
      case 'overdue':
        markerColor = Colors.red;
        markerIcon = Icons.warning;
        break;
      case 'verified':
        markerColor = Colors.purple;
        markerIcon = Icons.verified;
        break;
      default:
        markerColor = Colors.grey;
        markerIcon = Icons.help;
    }

    return Container(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        markerIcon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
