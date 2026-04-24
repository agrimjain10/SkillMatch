import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/gamification_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HONOR ARCHIVE', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.brutalistDecoration(
                color: AppTheme.tertiaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAILY STREAK',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CURRENT: ${streakAsync.value?['streak_count'] ?? 0} DAYS',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final msg = await ref
                            .read(gamificationServiceProvider)
                            .claimDailyStreak();
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('STREAK FAILED: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.local_fire_department),
                    label: const Text('CLAIM TODAY'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            badgesAsync.when(
              data: (badges) {
                if (badges.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'NO BADGES EARNED YET. CLAIM STREAK OR COMPLETE EVALUATIONS.',
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge =
                        badges[index]['badge'] as Map<String, dynamic>? ??
                        badges[index];
                    return Container(
                      decoration: AppTheme.brutalistDecoration(
                        color: index.isEven
                            ? AppTheme.secondaryContainer
                            : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            (badge['name'] ?? 'BADGE').toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.ink),
              ),
              error: (e, _) => Center(child: Text('BADGE LOAD FAILED: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
