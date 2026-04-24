import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_provider.dart';

final connectionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return Stream.value([]);

  return supabase
      .from('matches')
      .stream(primaryKey: ['id'])
      .eq('status', 'matched')
      .map((list) => list.where((m) => m['user1_id'] == userId || m['user2_id'] == userId).toList());
});

class SocialService {
  final Ref ref;
  SocialService(this.ref);

  Future<void> removeConnection(String matchId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('matches').delete().eq('id', matchId);
  }
}

final socialServiceProvider = Provider<SocialService>((ref) => SocialService(ref));
