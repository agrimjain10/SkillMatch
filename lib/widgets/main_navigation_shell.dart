import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class MainNavigationShell extends ConsumerWidget {
  final Widget child;
  const MainNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String location;
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      location = '/home';
    }
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          if (isDesktop)
            _Sidebar(
              currentLocation: location,
              isAdmin: ref.watch(isAdminProvider),
            ),
          Expanded(
            child: GridBackground(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: !isDesktop ? 72 : 0),
                    child: child,
                  ),
                  if (!isDesktop) _MobileBottomNav(currentLocation: location),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentLocation;
  final bool isAdmin;
  const _Sidebar({required this.currentLocation, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(right: BorderSide(color: AppTheme.ink, width: 2)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.school, size: 32),
              const SizedBox(width: 12),
              Text(
                'SkillMatch',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _NavButton(
            label: 'DASHBOARD',
            icon: Icons.dashboard,
            route: '/home',
            current: currentLocation,
          ),
          _NavButton(
            label: 'EXPLORE',
            icon: Icons.search,
            route: '/discover',
            current: currentLocation,
          ),
          _NavButton(
            label: 'PROJECTS',
            icon: Icons.extension,
            route: '/projects',
            current: currentLocation,
          ),
          _NavButton(
            label: 'CHATS',
            icon: Icons.chat_bubble_outline,
            route: '/chats',
            current: currentLocation,
          ),
          _NavButton(
            label: 'QUIZ CENTER',
            icon: Icons.quiz,
            route: '/quiz',
            current: currentLocation,
          ),
          _NavButton(
            label: 'LEADERBOARD',
            icon: Icons.leaderboard,
            route: '/leaderboard',
            current: currentLocation,
          ),
          if (isAdmin)
            _NavButton(
              label: 'ADMIN',
              icon: Icons.admin_panel_settings,
              route: '/admin',
              current: currentLocation,
            ),
          const Spacer(),
          _NavButton(
            label: 'MY PROFILE',
            icon: Icons.person,
            route: '/profile',
            current: currentLocation,
          ),
          _NavButton(
            label: 'SETTINGS',
            icon: Icons.settings,
            route: '/settings',
            current: currentLocation,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final String current;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.route,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == route;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: isSelected
              ? AppTheme.brutalistDecoration(
                  color: AppTheme.tertiaryContainer,
                  radius: 8,
                )
              : null,
          child: Row(
            children: [
              Icon(icon, color: AppTheme.ink, size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final String currentLocation;
  const _MobileBottomNav({required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: AppTheme.ink, width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MobileIcon(
              icon: Icons.dashboard,
              label: 'HOME',
              route: '/home',
              current: currentLocation,
            ),
            _MobileIcon(
              icon: Icons.search,
              label: 'EXPLORE',
              route: '/discover',
              current: currentLocation,
            ),
            _MobileIcon(
              icon: Icons.extension,
              label: 'PROJECTS',
              route: '/projects',
              current: currentLocation,
            ),
            _MobileIcon(
              icon: Icons.chat_bubble_outline,
              label: 'CHATS',
              route: '/chats',
              current: currentLocation,
            ),
            _MobileIcon(
              icon: Icons.person,
              label: 'PROFILE',
              route: '/profile',
              current: currentLocation,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _MobileIcon({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == route;
    return InkWell(
      onTap: () => context.go(route),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.ink,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? AppTheme.primary : AppTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
