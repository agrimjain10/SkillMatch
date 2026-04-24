import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/gamification_provider.dart';

class PeerReviewScreen extends ConsumerWidget {
  const PeerReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PEER EVALUATION',
          style: TextStyle(letterSpacing: 4),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: matchesAsync.when(
          data: (matches) {
            final matched = matches
                .where((m) => m['status'] == 'matched')
                .toList();
            if (matched.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'NO MATCHED COLLABORATORS YET. MATCH SOMEONE FIRST.',
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: matched.length,
              itemBuilder: (context, index) {
                final other =
                    matched[index]['other_user'] as Map<String, dynamic>? ?? {};
                final name = (other['full_name'] ?? 'COLLABORATOR')
                    .toString()
                    .toUpperCase();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.brutalistDecoration(
                    color: AppTheme.lavender,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'READY FOR REVIEW',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'COLLABORATION WITH $name',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: List.generate(
                          5,
                          (i) => const Icon(
                            Icons.star,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(gamificationServiceProvider)
                              .addPoints(40);
                          await ref
                              .read(gamificationServiceProvider)
                              .awardBadge(
                                'PEER REVIEWER',
                                'Submitted a peer collaboration review for $name.',
                                40,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'REVIEW FOR $name SUBMITTED +40 XP',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('SUBMIT REVIEW'),
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
          error: (e, _) => Center(child: Text('REVIEW LOAD FAILED: $e')),
        ),
      ),
    );
  }
}
