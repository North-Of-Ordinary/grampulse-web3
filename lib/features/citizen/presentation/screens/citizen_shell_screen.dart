import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell screen for Citizen user role
/// Provides bottom navigation between:
/// - Home
/// - Explore
/// - My Reports
/// - Profile
class CitizenShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const CitizenShellScreen({
    required this.child,
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    // Only show FAB on Home and Explore tabs
    if (location == '/citizen/home' || location == '/citizen/explore') {
      return FloatingActionButton.extended(
        heroTag: "report_issue_fab_$location", // Unique hero tag
        onPressed: () => context.goNamed('report_issue'),
        label: const Text('Report Issue'),
        icon: const Icon(Icons.add_circle),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _calculateSelectedIndex(location),
      onTap: (int idx) => _onItemTapped(idx, context),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'My Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/citizen/home')) return 0;
    if (location.startsWith('/citizen/explore')) return 1;
    if (location.startsWith('/citizen/my-reports')) return 2;
    if (location.startsWith('/citizen/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed('citizen_home');
        break;
      case 1:
        context.goNamed('citizen_explore');
        break;
      case 2:
        context.goNamed('citizen_my_reports');
        break;
      case 3:
        context.goNamed('citizen_profile');
        break;
    }
  }
}
