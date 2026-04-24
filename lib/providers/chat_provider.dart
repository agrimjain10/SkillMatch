import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_provider.dart';

final chatListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final response = await supabase
      .from('matches')
      .select(
        '*, user1:users!matches_user1_id_fkey(*), user2:users!matches_user2_id_fkey(*)',
      )
      .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
      .inFilter('status', ['pending', 'matched'])
      .order('created_at', ascending: false);

  final List<Map<String, dynamic>> matches = List<Map<String, dynamic>>.from(
    response,
  );

  // Map matches to include the "other user" info easily
  return matches.map((m) {
    final isUser1 = m['user1_id'] == user.id;
    final otherUser = isUser1 ? m['user2'] : m['user1'];
    return {...m, 'other_user': otherUser};
  }).toList();
});

final messagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, matchId) {
      final supabase = ref.watch(supabaseClientProvider);
      var disposed = false;
      ref.onDispose(() => disposed = true);

      return (() async* {
        while (!disposed) {
          final response = await supabase
              .from('messages')
              .select()
              .eq('match_id', matchId)
              .order('created_at', ascending: true);
          yield List<Map<String, dynamic>>.from(response);
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      })();
    });

class ChatService {
  final Ref ref;
  ChatService(this.ref);

  Future<void> sendMessage({
    required String matchId,
    required String body,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    final text = body.trim();
    if (user == null || text.isEmpty) return;

    final match = await supabase
        .from('matches')
        .select('id, status, user1_id, user2_id')
        .eq('id', matchId)
        .maybeSingle();

    if (match == null || match['status'] != 'matched') {
      throw Exception('CHAT LOCKED UNTIL BOTH USERS MATCH');
    }

    try {
      await supabase.from('messages').insert({
        'match_id': matchId,
        'sender_id': user.id,
        'content': text,
      });
      ref.invalidate(messagesProvider(matchId));
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw Exception(
          'SUPABASE RLS BLOCKED MESSAGES INSERT. RUN supabase/skillmatch_schema.sql',
        );
      }
      rethrow;
    }
  }

  Future<String> requestMatch(String targetUserId) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null || targetUserId == user.id) return 'ignored';

    final reciprocal = await supabase
        .from('matches')
        .select('id')
        .eq('user1_id', targetUserId)
        .eq('user2_id', user.id)
        .eq('status', 'pending')
        .maybeSingle();

    if (reciprocal != null) {
      await supabase
          .from('matches')
          .update({'status': 'matched'})
          .eq('id', reciprocal['id']);
      ref.invalidate(chatListProvider);
      return reciprocal['id'].toString();
    }

    final existing = await supabase
        .from('matches')
        .select('id, status')
        .eq('user1_id', user.id)
        .eq('user2_id', targetUserId)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('matches').insert({
        'user1_id': user.id,
        'user2_id': targetUserId,
        'status': 'pending',
      });
    }

    ref.invalidate(chatListProvider);
    return existing?['status'] == 'matched'
        ? existing!['id'].toString()
        : 'pending';
  }
}

final chatServiceProvider = Provider<ChatService>((ref) => ChatService(ref));
