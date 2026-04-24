import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

class PersonalityQuizScreen extends ConsumerStatefulWidget {
  const PersonalityQuizScreen({super.key});

  @override
  ConsumerState<PersonalityQuizScreen> createState() => _PersonalityQuizScreenState();
}

class _PersonalityQuizScreenState extends ConsumerState<PersonalityQuizScreen> {
  int _currentQuestion = 0;
  final List<String> _questions = [
    "I PREFER STRUCTURED WORKFLOWS OVER CHAOTIC CREATIVITY.",
    "I THRIVE IN RAPID PROTOTYPING ENVIRONMENTS.",
    "I PRIORITIZE LOGIC OVER AESTHETICS.",
    "I AM A NATURAL BORN ARCHITECT."
  ];

  void _next() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // We don't complete onboarding here yet, we go to the "Ready" screen first
    if (mounted) context.push('/setup/ready');
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'QUESTION ${_currentQuestion + 1}/${_questions.length}',
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: AppTheme.ink.withValues(alpha: 0.1),
                color: AppTheme.primaryContainer,
              ),
              const SizedBox(height: 64),
              Text(
                _questions[_currentQuestion],
                style: theme.textTheme.headlineMedium,
              ).animate(key: ValueKey(_currentQuestion)).fadeIn().slideX(),
              const SizedBox(height: 64),
              _QuizButton(label: 'STRONGLY AGREE', onTap: _next, color: AppTheme.tertiaryContainer),
              const SizedBox(height: 16),
              _QuizButton(label: 'DISAGREE', onTap: _next, color: AppTheme.secondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _QuizButton({required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.brutalistDecoration(color: color),
        child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }
}
