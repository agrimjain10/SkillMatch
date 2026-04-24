import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_provider.dart';
import 'auth_provider.dart';

final localBadgesProvider =
    NotifierProvider<LocalBadgesNotifier, List<Map<String, dynamic>>>(
      LocalBadgesNotifier.new,
    );

class LocalBadgesNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => const [];

  void add(String name, String description, int points) {
    if (state.any((badge) => badge['name'] == name)) return;
    state = [
      ...state,
      {'name': name, 'description': description, 'points': points},
    ];
  }
}

final localStreakProvider = NotifierProvider<LocalStreakNotifier, int>(
  LocalStreakNotifier.new,
);

class LocalStreakNotifier extends Notifier<int> {
  @override
  int build() => 0;

  int claim() {
    state += 1;
    return state;
  }
}

final badgeCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase
        .from('badges')
        .select()
        .order('points', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  } catch (_) {
    return ref.watch(localBadgesProvider);
  }
});

final userBadgesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];
  try {
    final response = await supabase
        .from('user_badges')
        .select('*, badge:badges(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (_) {
    return ref
        .watch(localBadgesProvider)
        .map((badge) => {'badge': badge})
        .toList();
  }
});

final streakProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  try {
    final response = await supabase
        .from('user_streaks')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    return response == null ? null : Map<String, dynamic>.from(response);
  } catch (_) {
    final localCount = ref.watch(localStreakProvider);
    return localCount == 0 ? null : {'streak_count': localCount};
  }
});

class GamificationService {
  final Ref ref;
  GamificationService(this.ref);

  Future<String> claimDailyStreak() async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('AUTH REQUIRED');

    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    Map<String, dynamic>? existing;
    try {
      existing = await supabase
          .from('user_streaks')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      if (existing != null &&
          existing['last_claim_date']?.toString() == today) {
        return 'STREAK ALREADY CLAIMED TODAY';
      }
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST205' && e.code != '404') rethrow;
      final count = ref.read(localStreakProvider.notifier).claim();
      ref
          .read(localBadgesProvider.notifier)
          .add(
            'DAILY STREAK',
            'Claimed a local daily SkillMatch streak. Run SQL to sync cloud.',
            25,
          );
      ref.invalidate(streakProvider);
      ref.invalidate(userBadgesProvider);
      return 'DAY $count STREAK COMPLETE LOCALLY. RUN SQL TO SYNC CLOUD';
    }

    final previousCount =
        int.tryParse('${existing?['streak_count'] ?? 0}') ?? 0;
    final nextCount = previousCount + 1;
    try {
      await supabase.from('user_streaks').upsert({
        'user_id': user.id,
        'last_claim_date': today,
        'streak_count': nextCount,
      });
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST205' && e.code != '404') rethrow;
    }
    await addPoints(25);
    await awardBadge('DAILY STREAK', 'Claimed a daily SkillMatch streak.', 25);
    if (nextCount >= 3) {
      await awardBadge('3 DAY STREAK', 'Checked in for 3 days.', 75);
    }
    ref.invalidate(streakProvider);
    return 'DAY $nextCount STREAK COMPLETE';
  }

  Future<void> addPoints(int points) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final profile = ref.read(userProvider);
    try {
      final current = await supabase
          .from('users')
          .select('total_points')
          .eq('id', user.id)
          .maybeSingle();
      final total =
          (int.tryParse('${current?['total_points'] ?? 0}') ?? 0) + points;
      await supabase.from('users').upsert({
        'id': user.id,
        'email': profile?.email ?? user.email,
        'full_name': profile?.fullName ?? '',
        'role': profile?.role ?? 'CONTRIBUTOR',
        'total_points': total,
      });
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST204' && e.code != '42703') rethrow;
    }
  }

  Future<void> awardBadge(String name, String description, int points) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final badge = await supabase
          .from('badges')
          .upsert({
            'name': name,
            'description': description,
            'points': points,
          }, onConflict: 'name')
          .select('id')
          .single();
      await supabase.from('user_badges').upsert({
        'user_id': user.id,
        'badge_id': badge['id'],
      });
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST205' && e.code != '404') rethrow;
      ref.read(localBadgesProvider.notifier).add(name, description, points);
    }
    ref.invalidate(userBadgesProvider);
    ref.invalidate(badgeCatalogProvider);
  }
}

final gamificationServiceProvider = Provider<GamificationService>(
  (ref) => GamificationService(ref),
);
