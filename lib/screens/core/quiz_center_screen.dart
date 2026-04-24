import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/supabase_provider.dart';

final quizzesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase
        .from('quizzes')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (_) {
    return [];
  }
});

class QuizCenterScreen extends ConsumerWidget {
  const QuizCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SKILL ASSESSMENT', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridBackground(
        child: quizzesAsync.when(
          data: (quizzes) {
            if (quizzes.isEmpty) return const Center(child: Text('NO ACTIVE EVALUATIONS CONFIGURED.'));
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return _QuizCard(
                  title: (quiz['title'] ?? 'UNTITLED EVALUATION').toString(),
                  questions: quiz['question_count'] as int? ?? 0,
                  color: index.isEven ? AppTheme.secondaryContainer : AppTheme.tertiaryContainer,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.ink)),
          error: (e, _) => Center(child: Text('EVALUATION LOAD FAILED: $e')),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final int questions;
  final Color color;
  const _QuizCard({required this.title, required this.questions, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.brutalistDecoration(color: color),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text('$questions QUESTIONS • 10 MINS', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.play_arrow_rounded, size: 32),
        ],
      ),
    );
  }
}
