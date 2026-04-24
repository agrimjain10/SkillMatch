import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/gamification_provider.dart';

class SkillAssessmentScreen extends ConsumerWidget {
  const SkillAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SKILL VALIDATION',
          style: TextStyle(letterSpacing: 4),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _AssessmentCard(
              title: 'UI/UX MASTERY',
              questions: 20,
              difficulty: 'HARD',
              color: AppTheme.primaryContainer,
              onComplete: () => _complete(context, ref, 'UI/UX MASTERY'),
            ),
            const SizedBox(height: 16),
            _AssessmentCard(
              title: 'DART PROTOCOLS',
              questions: 15,
              difficulty: 'ELITE',
              color: AppTheme.secondaryContainer,
              onComplete: () => _complete(context, ref, 'DART PROTOCOLS'),
            ),
            const SizedBox(height: 16),
            _AssessmentCard(
              title: 'SYSTEM ARCHITECTURE',
              questions: 25,
              difficulty: 'MASTER',
              color: AppTheme.tertiaryContainer,
              onComplete: () => _complete(context, ref, 'SYSTEM ARCHITECTURE'),
            ),
            const SizedBox(height: 16),
            _AssessmentCard(
              title: 'REACTION GRID GAME',
              questions: 10,
              difficulty: 'GAME',
              color: Colors.white,
              onComplete: () async => context.push('/reaction-game'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) async {
    await ref.read(gamificationServiceProvider).addPoints(60);
    await ref
        .read(gamificationServiceProvider)
        .awardBadge(title, 'Completed $title evaluation.', 60);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title COMPLETE +60 XP +BADGE')));
    }
  }
}

class _AssessmentCard extends StatelessWidget {
  final String title;
  final int questions;
  final String difficulty;
  final Color color;
  final Future<void> Function() onComplete;
  const _AssessmentCard({
    required this.title,
    required this.questions,
    required this.difficulty,
    required this.color,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.brutalistDecoration(color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                difficulty,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
              const Icon(Icons.timer_outlined, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            '$questions QUESTIONS • 30 MINUTES',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
            ),
            child: const Text('BEGIN EVALUATION'),
          ),
        ],
      ),
    );
  }
}
