import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'SYSTEM CONFIG',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
          onPressed: () => context.pop(),
        ),
      ),
      body: GridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'PREFERENCES',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.notifications_none,
              title: 'NOTIFICATIONS',
              subtitle: 'MANAGE ALERTS AND UPDATES',
              onTap: () => context.push('/notifications'),
            ),
            _SettingsTile(
              icon: Icons.security,
              title: 'PRIVACY VAULT',
              subtitle: 'CONTROL DATA VISIBILITY',
              onTap: () => context.push('/settings/privacy-vault'),
            ),
            _SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'INTERFACE THEME',
              subtitle: ref.watch(darkModeProvider)
                  ? 'DARK MODE ENABLED'
                  : 'LIGHT MODE ENABLED',
              onTap: () {
                ref.read(darkModeProvider.notifier).toggle();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(darkModeProvider)
                          ? 'DARK MODE ENABLED'
                          : 'LIGHT MODE ENABLED',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'FEATURES',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.leaderboard,
              title: 'LEADERBOARD',
              subtitle: 'REAL USER RANKING ARCHIVE',
              onTap: () => context.push('/leaderboard'),
            ),
            _SettingsTile(
              icon: Icons.workspace_premium,
              title: 'BADGES',
              subtitle: 'EARNED ACHIEVEMENTS',
              onTap: () => context.push('/badges'),
            ),
            _SettingsTile(
              icon: Icons.rate_review,
              title: 'PEER REVIEW',
              subtitle: 'COLLABORATION FEEDBACK',
              onTap: () => context.push('/peer-review'),
            ),
            _SettingsTile(
              icon: Icons.quiz,
              title: 'SKILL ASSESSMENT',
              subtitle: 'ACTIVE EVALUATIONS',
              onTap: () => context.push('/skill-assessment'),
            ),
            _SettingsTile(
              icon: Icons.manage_search,
              title: 'ADVANCED SEARCH',
              subtitle: 'FILTER TALENT AND PROJECTS',
              onTap: () => context.push('/search/advanced'),
            ),
            const SizedBox(height: 32),
            Text(
              'ACCOUNT',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'EDIT PROFILE',
              subtitle: 'UPDATE DOSSIER INFORMATION',
              onTap: () => context.push('/profile/edit'),
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'SUPPORT CENTER',
              subtitle: 'GET HELP WITH THE PLATFORM',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SUPPORT CENTER OFFLINE')),
                );
              },
            ),
            if (isAdmin)
              _SettingsTile(
                icon: Icons.admin_panel_settings,
                title: 'ADMIN COMMAND CENTER',
                subtitle: 'MODERATE USERS, PROJECTS, MATCHES',
                onTap: () => context.push('/admin'),
              ),
            const SizedBox(height: 40),
            Text(
              'DANGER ZONE',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
                color: Colors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('TERMINATE SESSION?'),
                      content: const Text(
                        'You will be logged out of the archive.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'TERMINATE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('TERMINATE SESSION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D4D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.brutalistDecoration(
                color: AppTheme.surfaceContainer,
              ),
              child: Column(
                children: [
                  Text(
                    'SKILLMATCH v1.0.0',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'CAMPUS COLLABORATION PROTOCOL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CONNECTED TO SUPABASE CLOUD',
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.brutalistDecoration(color: Colors.white),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  border: Border.all(color: AppTheme.ink, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.ink.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.ink),
            ],
          ),
        ),
      ),
    );
  }
}
