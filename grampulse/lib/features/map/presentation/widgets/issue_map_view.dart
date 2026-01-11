import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:grampulse/core/constants/spacing.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:latlong2/latlong.dart';

class IssueMapView extends StatelessWidget {
  final List<IssueModel> issues;
  final LatLng userLocation;
  final String? selectedCategory;
  final Function(IssueModel) onIssueSelected;
  final Function() onUserLocationRequest;
  
  const IssueMapView({
    Key? key,
    required this.issues,
    required this.userLocation,
    this.selectedCategory,
    required this.onIssueSelected,
    required this.onUserLocationRequest,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final filteredIssues = selectedCategory != null && selectedCategory != 'all'
        ? issues.where((issue) => issue.category.id == selectedCategory).toList()
        : issues;
    
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: userLocation,
            zoom: 14.0,
            maxZoom: 18.0,
            minZoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'dev.grampulse.app',
            ),
            // User location marker
            MarkerLayer(
              markers: [
                // User location marker
                Marker(
                  point: userLocation,
                  child: Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Issue markers
            MarkerLayer(
              markers: filteredIssues.map((issue) {
                return Marker(
                  point: LatLng(issue.latitude, issue.longitude),
                  child: GestureDetector(
                    onTap: () => onIssueSelected(issue),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: issue.category.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          width: 24,
                          height: 24,
                          child: Icon(
                            IconData(
                              int.parse(issue.category.iconCode),
                              fontFamily: 'MaterialIcons',
                            ),
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            // Attribution text
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
        
        // Map controls
        Positioned(
          bottom: Spacing.md,
          right: Spacing.md,
          child: Column(
            children: [
              MapControlButton(
                icon: Icons.layers,
                onPressed: () {},
              ),
              SizedBox(height: Spacing.sm),
              MapControlButton(
                icon: Icons.add,
                onPressed: () {},
              ),
              SizedBox(height: Spacing.sm),
              MapControlButton(
                icon: Icons.remove,
                onPressed: () {},
              ),
              SizedBox(height: Spacing.sm),
              MapControlButton(
                icon: Icons.my_location,
                onPressed: onUserLocationRequest,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  
  const MapControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 20,
      ),
    );
  }
}
