import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grampulse/features/map/domain/models/category_model.dart';
import 'package:grampulse/features/map/domain/models/issue_model.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_bloc.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_event.dart';
import 'package:grampulse/features/map/presentation/bloc/nearby_map_state.dart';
import 'package:grampulse/features/map/presentation/widgets/category_filter_bar.dart';
import 'package:grampulse/features/map/presentation/widgets/issue_bottom_sheet.dart';
import 'package:grampulse/features/map/presentation/widgets/issue_map_view.dart';
import 'package:grampulse/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyMapScreen extends StatelessWidget {
  const NearbyMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NearbyMapBloc()..add(const LoadMap()),
      child: const _NearbyMapView(),
    );
  }
}

class _NearbyMapView extends StatelessWidget {
  const _NearbyMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.nearbyIssues),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: BlocBuilder<NearbyMapBloc, NearbyMapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is MapLoaded || state is MapSelectingIssue) {
            final issues = state is MapLoaded ? state.issues : (state as MapSelectingIssue).issues;
            final userLocation = state is MapLoaded ? state.userLocation : (state as MapSelectingIssue).userLocation;
            final selectedCategory = state is MapLoaded ? state.selectedCategory : (state as MapSelectingIssue).selectedCategory;
            
            return Stack(
              children: [
                // Map
                IssueMapView(
                  issues: issues,
                  userLocation: userLocation,
                  selectedCategory: selectedCategory,
                  onIssueSelected: (issue) {
                    context.read<NearbyMapBloc>().add(SelectIssue(issue));
                  },
                  onUserLocationRequest: () {
                    // Request current location
                  },
                ),
                
                // Category filter bar at the top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CategoryFilterBar(
                    categories: _getUniqueCategories(issues),
                    selectedCategoryId: selectedCategory,
                    onCategorySelected: (categoryId) {
                      context.read<NearbyMapBloc>().add(FilterByCategory(categoryId));
                    },
                  ),
                ),
                
                // Bottom sheet for selected issue
                if (state is MapSelectingIssue)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: IssueBottomSheet(
                      issue: state.selectedIssue,
                      onViewDetails: () {
                        // Navigate to issue details screen
                        context.read<NearbyMapBloc>().add(ViewIssueDetails(state.selectedIssue));
                      },
                      onNavigate: () {
                        // Open maps app for navigation
                        _launchMapsApp(state.selectedIssue);
                      },
                    ),
                  ),
              ],
            );
          }
          
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
  
  // Helper method to extract unique categories from issues
  List<CategoryModel> _getUniqueCategories(List<IssueModel> issues) {
    final uniqueCategories = <String, CategoryModel>{};
    
    for (final issue in issues) {
      uniqueCategories[issue.category.id] = issue.category;
    }
    
    return uniqueCategories.values.toList();
  }
  
  // Helper method to launch maps app for navigation
  Future<void> _launchMapsApp(IssueModel issue) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${issue.latitude},${issue.longitude}'
    );
    
    try {
      await launchUrl(url);
    } catch (e) {
      print('Could not launch $url: $e');
    }
  }
}

// Custom tile provider for caching (simplified version)
class CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // This would implement tile caching for offline support
    // For now, just return the network image
    String urlTemplate = options.urlTemplate ?? 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    final url = urlTemplate
        .replaceAll('{z}', '${coordinates.z}')
        .replaceAll('{x}', '${coordinates.x}')
        .replaceAll('{y}', '${coordinates.y}')
        .replaceAll('{s}', _getSubdomain(coordinates, options.subdomains));
    
    return NetworkImage(url);
  }
  
  String _getSubdomain(TileCoordinates coordinates, List<String>? subdomains) {
    final subs = subdomains ?? ['a', 'b', 'c'];
    if (subs.isEmpty) return '';
    final index = (coordinates.x + coordinates.y) % subs.length;
    return subs[index];
  }
}
