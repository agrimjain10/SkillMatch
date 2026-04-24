import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/project_provider.dart';

class ProjectsBoard extends ConsumerWidget {
  const ProjectsBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROJECT ARCHIVE', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/projects/new'),
            icon: const Icon(Icons.add_box, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridBackground(
        child: projectsAsync.when(
          data: (projects) => projects.isEmpty 
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _ProjectTile(project: project);
                },
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('ERROR LOADING ARCHIVE: $e')),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.ink.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text('NO ACTIVE MISSIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 12),
          const Text('INITIATE A NEW PROJECT TO BEGIN.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.push('/projects/new'),
            child: const Text('CREATE NEW PROJECT'),
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final dynamic project;
  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/project/detail/${project['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.brutalistDecoration(
          color: AppTheme.surfaceContainerLowest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    border: Border.all(color: AppTheme.ink, width: 1.5),
                  ),
                  child: Text(
                    (project['category'] ?? 'GENERAL').toString().toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              project['title'] ?? 'UNTITLED MISSION',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              project['description'] ?? 'NO DESCRIPTION PROVIDED.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(radius: 12, backgroundColor: AppTheme.ink),
                const SizedBox(width: 8),
                Text(
                  (project['creator']?['full_name'] ?? 'UNKNOWN CREATOR').toString().toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  _dateLabel(project['created_at']),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(dynamic createdAt) {
    final date = DateTime.tryParse(createdAt?.toString() ?? '');
    if (date == null) return 'NO DATE';
    final days = DateTime.now().difference(date.toLocal()).inDays;
    if (days <= 0) return 'TODAY';
    if (days == 1) return '1D AGO';
    return '${days}D AGO';
  }
}
