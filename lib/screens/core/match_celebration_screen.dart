import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MatchCelebrationScreen extends StatelessWidget {
  final String matchId;
  final Map<String, dynamic> matchedUser;

  const MatchCelebrationScreen({
    super.key,
    required this.matchId,
    required this.matchedUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = (matchedUser['full_name'] ?? 'MATCH').toString().toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CelebrationBackgroundPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'COMPATIBILITY CONFIRMED',
                  style: TextStyle(color: AppTheme.tertiaryContainer, letterSpacing: 4, fontWeight: FontWeight.bold),
                ).animate().fadeIn().slideY(begin: 1),
                const SizedBox(height: 12),
                Text(
                  'LINK ESTABLISHED WITH $name',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 32),
                ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 48),
                AppTheme.sticker(
                  angle: -0.05,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: AppTheme.brutalistDecoration(color: AppTheme.primaryContainer),
                    child: matchedUser['avatar_url'] != null
                        ? Image.network(matchedUser['avatar_url'], fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 80),
                  ),
                ).animate().shimmer(delay: 500.ms),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: () => context.pushReplacement('/chat/$matchId?name=${Uri.encodeComponent(name)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryContainer,
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text('INITIATE TRANSMISSION (CHAT)'),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('RESUME DISCOVERY', style: TextStyle(color: Colors.white60)),
                ).animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Simple geometric celebration patterns
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
