import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/gamification_provider.dart';

class HomeDashboard extends ConsumerStatefulWidget {
  const HomeDashboard({super.key});

  @override
  ConsumerState<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends ConsumerState<HomeDashboard> {
  bool _streakPromptShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_streakPromptShown) return;
    _streakPromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showDailyStreakPrompt(),
    );
  }

  Future<void> _showDailyStreakPrompt() async {
    if (!mounted) return;
    final claim = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CLAIM TODAY?'),
        content: const Text('Daily streak gives XP and unlocks badges.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('LATER'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('CLAIM STREAK'),
          ),
        ],
      ),
    );
    if (claim != true || !mounted) return;
    try {
      final msg = await ref
          .read(gamificationServiceProvider)
          .claimDailyStreak();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('STREAK FAILED: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final projectsAsync = ref.watch(allProjectsProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final stats = statsAsync.value ?? {'projects': 0, 'matches': 0, 'xp': 0};
    final matches = stats['matches'] ?? 0;
    final xp = stats['xp'] ?? 0;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          if (!isDesktop) const _MobileHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, isDesktop ? 48 : 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(user?.fullName ?? 'USER'),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isTight = constraints.maxWidth < 520;
                      final cards = [
                        _StatCard(
                          label: 'ACTIVE MATCHES',
                          value: '$matches',
                          icon: Icons.people,
                        ),
                        _StatCard(
                          label: 'SKILL XP',
                          value: '$xp',
                          icon: Icons.bolt,
                        ),
                        _StatCard(
                          label: 'MATCH RATE',
                          value: matches > 0 ? '92%' : '0%',
                          icon: Icons.analytics,
                        ),
                      ];

                      if (isTight) {
                        return Column(
                          children: cards
                              .map(
                                (card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      }

                      return Row(
                        children: cards
                            .map(
                              (card) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: card,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  _buildBentoGrid(context, projectsAsync, stats),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HI, ${name.toUpperCase()}!',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.ink, width: 1.5),
          ),
          child: Text(
            'READY TO COLLABORATE AND BUILD SOMETHING NEW?',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppTheme.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(
    BuildContext context,
    AsyncValue<List<dynamic>> projectsAsync,
    Map<String, int> stats,
  ) {
    final matches = stats['matches'] ?? 0;
    final projectsCount = stats['projects'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : (constraints.maxWidth > 700 ? 3 : 1);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          mainAxisExtent: constraints.maxWidth < 520 ? 210 : 230,
          children: [
            _BentoBox(
              color: AppTheme.tertiaryContainer,
              title: '$matches ACTIVE\nMATCHES',
              subtitle: 'Connect with developers ready to collaborate.',
              icon: Icons.extension,
              onTap: () => context.push('/chats'),
              isLarge: true,
            ),
            _BentoBox(
              color: AppTheme.secondaryContainer,
              title: 'EXPLORE\nTALENT',
              subtitle: 'Find new skills in the archive.',
              icon: Icons.group_add,
              onTap: () => context.push('/discover'),
            ),
            _BentoBox(
              color: AppTheme.surfaceContainerLowest,
              title: '$matches',
              subtitle: 'MATCHED CONNECTIONS',
              label: 'LIVE ARCHIVE',
              icon: Icons.mail_outline,
              onTap: () => context.push('/notifications'),
            ),
            _BentoBox(
              color: AppTheme.surfaceContainerLowest,
              title: '$projectsCount',
              subtitle: 'ACTIVE PROJECTS',
              label: 'ON TRACK',
              icon: Icons.handshake,
              onTap: () => context.push('/projects'),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.brutalistDecoration(),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoBox extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String? label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLarge;

  const _BentoBox({
    required this.color,
    required this.title,
    required this.subtitle,
    this.label,
    required this.icon,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.brutalistDecoration(color: color, radius: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border.all(color: AppTheme.ink, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Icon(icon, size: 32, color: AppTheme.ink),
            const SizedBox(height: 20),
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: isLarge ? 28 : 22,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.ink.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.ink, width: 2)),
          color: AppTheme.background,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: () => context.push('/settings'),
            ),
            Text(
              'SKILLMATCH',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: const CircleAvatar(
                backgroundColor: AppTheme.ink,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
