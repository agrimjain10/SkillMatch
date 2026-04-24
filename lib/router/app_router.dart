import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/email_login_screen.dart';
import '../screens/auth/email_otp_screen.dart';
import '../screens/onboarding/walkthrough_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/onboarding/profile_bio_screen.dart';
import '../screens/onboarding/profile_photo_screen.dart';
import '../screens/onboarding/profile_skills_screen.dart';
import '../screens/onboarding/personality_quiz_screen.dart';
import '../screens/onboarding/profile_ready_screen.dart';
import '../screens/profile/setup_screen.dart' as profile_edit;
import '../screens/core/home_dashboard.dart';
import '../screens/core/discover_screen.dart';
import '../screens/core/projects_board.dart';
import '../screens/profile/my_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/privacy_vault_screen.dart';
import '../screens/project/project_detail_screen.dart';
import '../screens/chat/individual_chat_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/core/quiz_center_screen.dart';
import '../screens/core/leaderboard_screen.dart';
import '../screens/core/notifications_center.dart';
import '../screens/core/create_project_screen.dart';
import '../screens/core/advanced_search_screen.dart';
import '../screens/core/badges_screen.dart';
import '../screens/core/peer_review_screen.dart';
import '../screens/core/admin_dashboard.dart';
import '../screens/core/match_celebration_screen.dart';
import '../screens/core/skill_assessment_screen.dart';
import '../screens/core/reaction_game_screen.dart';
import '../screens/project/manage_project_screen.dart';
import '../screens/project/project_roadmap_screen.dart';
import '../screens/profile/user_profile_public_screen.dart';
import '../widgets/main_navigation_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authListenableProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/walkthrough',
        builder: (context, state) => const WalkthroughScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) =>
            EmailOtpScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),

      // Onboarding Flow
      GoRoute(
        path: '/setup',
        builder: (context, state) => const ProfileSetupScreen(),
        routes: [
          GoRoute(
            path: 'bio',
            builder: (context, state) => const ProfileBioScreen(),
          ),
          GoRoute(
            path: 'photo',
            builder: (context, state) => const ProfilePhotoScreen(),
          ),
          GoRoute(
            path: 'skills',
            builder: (context, state) => const ProfileSkillsScreen(),
          ),
          GoRoute(
            path: 'ready',
            builder: (context, state) => const ProfileReadyScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding-quiz',
        builder: (context, state) => const PersonalityQuizScreen(),
      ),

      // Main Application Shell
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeDashboard(),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsBoard(),
          ),
          GoRoute(
            path: '/chats',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const MyProfileScreen(),
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) => const QuizCenterScreen(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
        ],
      ),

      // Non-shell routes
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'privacy-vault',
            builder: (context, state) => const PrivacyVaultScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const profile_edit.ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsCenter(),
      ),
      GoRoute(
        path: '/search/advanced',
        builder: (context, state) => const AdvancedSearchScreen(),
      ),
      GoRoute(
        path: '/badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/peer-review',
        builder: (context, state) => const PeerReviewScreen(),
      ),
      GoRoute(
        path: '/skill-assessment',
        builder: (context, state) => const SkillAssessmentScreen(),
      ),
      GoRoute(
        path: '/reaction-game',
        builder: (context, state) => const ReactionGameScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/match-celebration',
        builder: (context, state) {
          final data = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : <String, dynamic>{'full_name': 'NEW MATCH'};
          return MatchCelebrationScreen(
            matchId: state.uri.queryParameters['matchId'] ?? 'preview',
            matchedUser: data,
          );
        },
      ),
      GoRoute(
        path: '/project/detail/:id',
        builder: (context, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/manage/:id',
        builder: (context, state) =>
            ManageProjectScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/roadmap/:id',
        builder: (context, state) =>
            ProjectRoadmapScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) =>
            UserProfilePublicScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:matchId',
        builder: (context, state) => IndividualChatScreen(
          matchId: state.pathParameters['matchId']!,
          userName: state.uri.queryParameters['name'] ?? 'MATCH',
        ),
      ),
    ],
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final profileState = ref.read(profileStateProvider);

      final loc = state.matchedLocation;
      final isOnboarding =
          loc.startsWith('/setup') || loc == '/onboarding-quiz';
      final isAuth = loc == '/walkthrough' || loc == '/login' || loc == '/otp';
      final isSplash = loc == '/';

      final loggedIn = session != null;

      // 1. Handle Unauthenticated Users
      if (!loggedIn) {
        if (isAuth) return null;
        return '/walkthrough';
      }

      // 2. Handle Authenticated Users
      if (profileState == ProfileState.loading) return null;

      if (profileState == ProfileState.initial) {
        if (isOnboarding) return null;
        return '/setup';
      }

      if (profileState == ProfileState.complete) {
        if (isSplash || isAuth || isOnboarding) return '/home';
      }

      if (loc == '/admin' && !ref.read(isAdminProvider)) {
        return '/home';
      }

      return null;
    },
  );
});
