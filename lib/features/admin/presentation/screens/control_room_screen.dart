import 'package:flutter/material.dart';

class ControlRoomScreen extends StatelessWidget {
  const ControlRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Room'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Admin Control Room',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Coming Soon'),
          ],
        ),
      ),
    );
  }
}
