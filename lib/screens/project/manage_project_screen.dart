import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ManageProjectScreen extends StatelessWidget {
  final String projectId;
  const ManageProjectScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROJECT CONTROL'), backgroundColor: Colors.transparent, elevation: 0),
      body: GridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.brutalistDecoration(color: AppTheme.secondaryContainer),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTROL STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  SizedBox(height: 8),
                  Text('PROJECT IS LIVE AND DISCOVERABLE.', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('COLLABORATOR QUEUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.brutalistDecoration(),
              child: const Center(child: Text('NO PENDING REQUESTS')),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PROJECT TERMINATION REQUIRES ADMIN CONFIRMATION')),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('TERMINATE PROJECT'),
            ),
          ],
        ),
      ),
    );
  }
}
