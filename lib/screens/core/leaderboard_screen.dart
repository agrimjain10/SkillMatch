import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/supabase_provider.dart';

final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  List<dynamic> response;
  try {
    response = await supabase
        .from('users')
        .select('id, full_name, role, total_points, avatar_url')
        .limit(50);
  } on PostgrestException catch (e) {
    if (e.code != '42703' && e.code != 'PGRST204') rethrow;
    response = await supabase
        .from('users')
        .select('id, full_name, role, avatar_url')
        .limit(50);
  }
  for (final row in response) {
    if (row is Map && row['total_points'] == null) {
      var points = 0;
      final id = row['id']?.toString();
      if (id != null) {
        try {
          final projects = await supabase
              .from('projects')
              .select('id')
              .eq('created_by', id);
          final matches = await supabase
              .from('matches')
              .select('id')
              .or('user1_id.eq.$id,user2_id.eq.$id')
              .eq('status', 'matched');
          points = (projects.length * 100) + (matches.length * 50);
        } catch (_) {}
      }
      row['total_points'] = points;
    }
  }
  response.sort((a, b) {
    final ap = int.tryParse('${a['total_points'] ?? 0}') ?? 0;
    final bp = int.tryParse('${b['total_points'] ?? 0}') ?? 0;
    return bp.compareTo(ap);
  });
  return List<Map<String, dynamic>>.from(response);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            'RANKING ARCHIVE',
            style: theme.textTheme.headlineSmall?.copyWith(
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: leaderboardAsync.when(
            data: (rankings) {
              if (rankings.isEmpty) {
                return const Center(child: Text('NO DATA IN ARCHIVES'));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                itemCount: rankings.length,
                itemBuilder: (context, index) {
                  final user = rankings[index];
                  // Assign colors based on rank
                  Color cardColor = Colors.white;
                  if (index == 0) {
                    cardColor = AppTheme.tertiaryContainer;
                  } else if (index == 1) {
                    cardColor = AppTheme.secondaryContainer;
                  } else if (index == 2) {
                    cardColor = AppTheme.primaryContainer;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.brutalistDecoration(color: cardColor),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.ink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (user['full_name'] ?? 'ANON')
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                (user['role'] ?? 'CONTRIBUTOR')
                                    .toString()
                                    .toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${user['total_points'] ?? 0} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
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
            error: (e, s) => Center(child: Text('TRANSMISSION ERR: $e')),
          ),
        ),
      ],
    );
  }
}
