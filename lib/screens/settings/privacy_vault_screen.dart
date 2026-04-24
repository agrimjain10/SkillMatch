import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class PrivacyVaultScreen extends ConsumerWidget {
  const PrivacyVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PRIVACY VAULT', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridBackground(
        child: userProfile == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _PrivacyToggle(
                    title: 'PUBLIC DISCOVERY',
                    subtitle: 'ALLOW OTHERS TO FIND YOU IN DISCOVER',
                    value: userProfile.openToCollab,
                    onChanged: (val) async {
                      await ref.read(userProvider.notifier).updateProfile({
                        'open_to_collab': val,
                      });
                    },
                  ),
                  _PrivacyToggle(
                    title: 'CONTACT VISIBILITY',
                    subtitle: 'ONLY SHOW EMAIL TO CONFIRMED MATCHES',
                    value: true,
                    onChanged: (val) {},
                  ),
                  _PrivacyToggle(
                    title: 'ANONYMOUS MODE',
                    subtitle: 'HIDE YOUR COURSE AND YEAR FROM PUBLIC',
                    value: false,
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.brutalistDecoration(color: AppTheme.secondaryContainer),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'YOUR DATA IS ENCRYPTED AND STORED SECURELY ACCORDING TO CAMPUS PROTOCOLS.',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.brutalistDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.ink.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
