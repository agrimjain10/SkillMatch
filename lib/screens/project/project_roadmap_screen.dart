import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProjectRoadmapScreen extends StatelessWidget {
  final String projectId;
  const ProjectRoadmapScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STRATEGIC MAP'), backgroundColor: Colors.transparent, elevation: 0),
      body: GridBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 4,
          itemBuilder: (context, index) {
            final stages = ['IDEATION', 'PROTOTYPING', 'BETA LAUNCH', 'SYSTEM SCALE'];
            final isDone = index < 2;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? AppTheme.primaryContainer : Colors.white,
                        border: Border.all(width: 2),
                      ),
                      child: isDone ? const Icon(Icons.check, size: 16) : null,
                    ),
                    if (index < 3) Container(width: 2, height: 60, color: Colors.black),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.brutalistDecoration(color: isDone ? Colors.white : AppTheme.surfaceContainerLowest),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stages[index], style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('PHASE ${index + 1} OF THE EVOLUTION.', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
