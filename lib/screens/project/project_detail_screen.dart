import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/project_provider.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final queuedLocally = ref
        .watch(localProjectEngagementsProvider)
        .contains(projectId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          'ARCHIVE DETAIL',
          style: theme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: projectAsync.when(
          data: (p) {
            final creator = p['creator']?['full_name'] ?? 'ARCHIVE CURATOR';
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.sticker(
                    angle: -0.02,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.brutalistDecoration(
                        color: AppTheme.secondaryContainer,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder, size: 32),
                          const SizedBox(height: 16),
                          Text(
                            (p['title'] ?? 'UNTITLED').toString().toUpperCase(),
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'INITIATED BY: ${creator.toUpperCase()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.ink.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('OBJECTIVE DOSSIER', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.brutalistDecoration(),
                    child: Text(
                      p['description'] ?? 'NO DATA AVAILABLE IN ARCHIVES.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/project/roadmap/$projectId'),
                          icon: const Icon(Icons.route),
                          label: const Text('ROADMAP'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/project/manage/$projectId'),
                          icon: const Icon(Icons.tune),
                          label: const Text('MANAGE'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final synced = await ref
                            .read(projectServiceProvider)
                            .requestCollaboration(projectId);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              synced
                                  ? 'COLLABORATION SIGNAL SENT'
                                  : 'REQUEST QUEUED. RUN SQL TO SYNC PROJECT MEMBERS.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('REQUEST FAILED: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: Text(
                      queuedLocally ? 'ENGAGE QUEUED' : 'ENGAGE PROJECT',
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.ink),
          ),
          error: (e, s) => Center(child: Text('TRANSMISSION ERROR: $e')),
        ),
      ),
    );
  }
}
