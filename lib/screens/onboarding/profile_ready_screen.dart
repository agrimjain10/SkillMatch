import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileReadyScreen extends ConsumerWidget {
  const ProfileReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 100, color: AppTheme.primaryContainer)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1200.ms),
              const SizedBox(height: 48),
              const Text(
                'PROFILE SYNCHRONIZED',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),
              const Text(
                'YOUR DIGITAL DOSSIER IS NOW ACTIVE WITHIN THE SKILLMATCH ECOSYSTEM.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(userProvider.notifier).completeOnboarding();
                  if (context.mounted) context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                ),
                child: const Text('ENTER SYSTEM', style: TextStyle(fontSize: 18)),
              ).animate().fadeIn(delay: 1200.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }
}
