import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/supabase_provider.dart';

final adminMetricsProvider = FutureProvider<Map<String, int>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);

  Future<int> countTable(String table, {String? status}) async {
    try {
      var query = supabase.from(table).select('id');
      if (status != null) query = query.eq('status', status);
      final response = await query.limit(1000);
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  return {
    'users': await countTable('users'),
    'projects': await countTable('projects'),
    'matches': await countTable('matches', status: 'matched'),
    'pending': await countTable('matches', status: 'pending'),
    'messages': await countTable('messages'),
  };
});

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final metrics = ref.watch(adminMetricsProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const GridBackground(
          child: Center(child: Text('ADMIN ACCESS REQUIRED')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SYSTEM CONTROL', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: metrics.when(
          data: (m) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.brutalistDecoration(
                  color: AppTheme.primaryContainer,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN COMMAND CENTER',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AGRIMJAIN056@GMAIL.COM HAS FULL ADMIN ACCESS.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _AdminTile(
                    icon: Icons.people,
                    label: 'USERS',
                    value: '${m['users']}',
                    color: AppTheme.secondaryContainer,
                  ),
                  _AdminTile(
                    icon: Icons.extension,
                    label: 'PROJECTS',
                    value: '${m['projects']}',
                    color: AppTheme.tertiaryContainer,
                  ),
                  _AdminTile(
                    icon: Icons.handshake,
                    label: 'MATCHED',
                    value: '${m['matches']}',
                    color: Colors.white,
                  ),
                  _AdminTile(
                    icon: Icons.lock_clock,
                    label: 'PENDING',
                    value: '${m['pending']}',
                    color: AppTheme.lavender,
                  ),
                  _AdminTile(
                    icon: Icons.chat_bubble_outline,
                    label: 'MESSAGES',
                    value: '${m['messages']}',
                    color: AppTheme.primaryContainer,
                  ),
                  const _AdminTile(
                    icon: Icons.verified_user,
                    label: 'ADMIN',
                    value: 'ON',
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'ADMIN ACTIONS',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              _AdminAction(
                icon: Icons.workspace_premium,
                title: 'SEED BADGES',
                subtitle: 'Create badge catalog and award admin test badge',
                onTap: () async {
                  await ref
                      .read(gamificationServiceProvider)
                      .awardBadge(
                        'ADMIN TESTER',
                        'Verified admin control center.',
                        100,
                      );
                  await ref.read(gamificationServiceProvider).addPoints(100);
                  ref.invalidate(adminMetricsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ADMIN BADGE SEEDED +100 XP'),
                      ),
                    );
                  }
                },
              ),
              _AdminAction(
                icon: Icons.leaderboard,
                title: 'OPEN LEADERBOARD',
                subtitle: 'Inspect live user XP ranking',
                onTap: () => context.push('/leaderboard'),
              ),
              _AdminAction(
                icon: Icons.rate_review,
                title: 'OPEN PEER REVIEWS',
                subtitle: 'Review matched collaborators',
                onTap: () => context.push('/peer-review'),
              ),
              _AdminAction(
                icon: Icons.extension,
                title: 'OPEN PROJECTS',
                subtitle: 'Inspect project archive',
                onTap: () => context.push('/projects'),
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.ink),
          ),
          error: (e, _) => Center(child: Text('ADMIN LOAD FAILED: $e')),
        ),
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.brutalistDecoration(color: Colors.white),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _AdminTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.brutalistDecoration(color: color),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
