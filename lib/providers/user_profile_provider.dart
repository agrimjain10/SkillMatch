import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_provider.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final response = await supabase
      .from('users')
      .select()
      .eq('id', user.id)
      .single();

  return response;
});

final discoverProfilesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) return [];

  final existingMatches = await supabase
      .from('matches')
      .select('id, user1_id, user2_id, status')
      .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}')
      .inFilter('status', ['pending', 'matched']);

  final hiddenUserIds = <String>{currentUser.id};
  final incomingPending = <String, String>{};
  for (final match in existingMatches) {
    final user1 = match['user1_id']?.toString();
    final user2 = match['user2_id']?.toString();
    final status = match['status']?.toString();
    if (user1 == null || user2 == null) continue;

    if (status == 'matched') {
      hiddenUserIds.add(user1);
      hiddenUserIds.add(user2);
      continue;
    }

    if (status == 'pending') {
      if (user1 == currentUser.id) {
        hiddenUserIds.add(user2);
      } else if (user2 == currentUser.id) {
        incomingPending[user1] = match['id'].toString();
      }
    }
  }

  final response = await supabase
      .from('users')
      .select('*, user_skills(skills(name))')
      .neq('id', currentUser.id)
      .or('open_to_collab.is.null,open_to_collab.eq.true')
      .limit(30);

  return List<Map<String, dynamic>>.from(response)
      .where((profile) => !hiddenUserIds.contains(profile['id']?.toString()))
      .map((profile) {
        final id = profile['id']?.toString();
        return {
          ...profile,
          if (id != null && incomingPending.containsKey(id))
            'incoming_match_id': incomingPending[id],
        };
      })
      .toList();
});

final publicUserProfileProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
      final supabase = ref.watch(supabaseClientProvider);
      final response = await supabase
          .from('users')
          .select('*, user_skills(skills(name))')
          .eq('id', userId)
          .maybeSingle();

      return response == null ? null : Map<String, dynamic>.from(response);
    });
