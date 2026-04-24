import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_provider.dart';

final localProjectEngagementsProvider =
    NotifierProvider<LocalProjectEngagementsNotifier, Set<String>>(
      LocalProjectEngagementsNotifier.new,
    );

class LocalProjectEngagementsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void add(String projectId) => state = {...state, projectId};
}

final allProjectsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final response = await supabase
      .from('projects')
      .select('*, creator:users!projects_created_by_fkey(*)')
      .or('status.is.null,status.eq.open,status.eq.active')
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});

final projectDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
      final supabase = ref.watch(supabaseClientProvider);

      final response = await supabase
          .from('projects')
          .select('*, creator:users!projects_created_by_fkey(*)')
          .eq('id', id)
          .single();

      return Map<String, dynamic>.from(response);
    });

class ProjectService {
  final Ref ref;
  ProjectService(this.ref);

  Future<void> createProject(Map<String, dynamic> data) async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      await supabase.from('projects').insert(data);
      ref.invalidate(allProjectsProvider);
    } catch (e) {
      throw Exception('PROJECT ARCHIVE ERROR: $e');
    }
  }

  Future<bool> requestCollaboration(String projectId) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('AUTHENTICATION REQUIRED');
    }

    final payload = {
      'project_id': projectId,
      'user_id': user.id,
      'status': 'pending',
    };

    try {
      final existing = await supabase
          .from('project_members')
          .select('project_id')
          .eq('project_id', projectId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('project_members').insert(payload);
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Already requested/joined.
      } else if (e.code == 'PGRST205' ||
          e.message.contains('project_members')) {
        ref.read(localProjectEngagementsProvider.notifier).add(projectId);
        ref.invalidate(projectDetailProvider(projectId));
        ref.invalidate(allProjectsProvider);
        return false;
      } else {
        rethrow;
      }
    }
    ref.invalidate(projectDetailProvider(projectId));
    ref.invalidate(allProjectsProvider);
    return true;
  }
}

final projectServiceProvider = Provider<ProjectService>(
  (ref) => ProjectService(ref),
);
