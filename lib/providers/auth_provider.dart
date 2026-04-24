import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

final authListenableProvider = Provider<AuthListenable>((ref) {
  final listenable = AuthListenable();
  ref.listen(authStateProvider, (previous, next) {
    listenable.update();
  });
  ref.listen(userProvider, (previous, next) {
    listenable.update();
  });
  ref.listen(profileStateProvider, (previous, next) {
    listenable.update();
  });
  return listenable;
});

class AuthListenable extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

final userProvider = NotifierProvider<UserNotifier, SkillMatchUser?>(UserNotifier.new);

final profileStateProvider = NotifierProvider<ProfileStateNotifier, ProfileState>(ProfileStateNotifier.new);

const adminEmails = {'agrimjain056@gmail.com'};

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  final email = user?.email.toLowerCase() ?? Supabase.instance.client.auth.currentUser?.email?.toLowerCase();
  return email != null && adminEmails.contains(email);
});

class ProfileStateNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => ProfileState.loading;
  
  void update(ProfileState newState) {
    state = newState;
  }
}



final userStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = ref.watch(userProvider);
  if (user == null) return {'projects': 0, 'matches': 0, 'xp': 0};

  try {
    final projectsRes = await supabase
        .from('projects')
        .select('id')
        .eq('created_by', user.id);
        
    final matchesRes = await supabase
        .from('matches')
        .select('id')
        .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
        .eq('status', 'matched');

    final projectsCount = projectsRes.length;
    final matchesCount = matchesRes.length;

    return {
      'projects': projectsCount,
      'matches': matchesCount,
      'xp': (projectsCount * 100) + (matchesCount * 50),
    };
  } catch (e) {
    debugPrint('STATS ERR: $e');
    return {'projects': 0, 'matches': 0, 'xp': 0};
  }
});

enum ProfileState { loading, initial, complete }

class UserNotifier extends Notifier<SkillMatchUser?> {
  @override
  SkillMatchUser? build() {
    ref.listen(authStateProvider, (previous, next) {
      final session = next.value?.session;
      if (session != null) {
        fetchProfile(session.user.id);
      } else {
        ref.read(profileStateProvider.notifier).update(ProfileState.initial);
        state = null;
      }
    });
    
    final initialSession = Supabase.instance.client.auth.currentSession;
    if (initialSession != null) {
      Future.microtask(() => fetchProfile(initialSession.user.id));
    } else {
      ref.read(profileStateProvider.notifier).update(ProfileState.initial);
    }
    
    return null;
  }

  Future<void> fetchProfile(String userId) async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      final response = await supabase
          .from('users')
          .select('*, user_skills(skills(name))')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        ref.read(profileStateProvider.notifier).update(ProfileState.initial);
        state = null;
        return;
      }

      if (response['onboarding_completed'] == true) {
        ref.read(profileStateProvider.notifier).update(ProfileState.complete);
      } else {
        ref.read(profileStateProvider.notifier).update(ProfileState.initial);
      }
      state = SkillMatchUser.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      ref.read(profileStateProvider.notifier).update(ProfileState.initial);
    }
  }

  Future<void> createInitialProfile({
    required String fullName,
    required String role,
    String? course,
    String? year,
    String? bio,
    List<String> skills = const [],
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('users').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': user.email,
        'role': role,
        'course': course,
        'year': year,
        'bio': bio,
      });

      // Handle skills if provided
      if (skills.isNotEmpty) {
        // First get skill IDs for the names
        final skillsRes = await supabase
            .from('skills')
            .select('id, name')
            .inFilter('name', skills);
        
        if (skillsRes.isNotEmpty) {
          final userSkills = skillsRes.map((s) => {
            'user_id': user.id,
            'skill_id': s['id'],
          }).toList();
          
          await supabase.from('user_skills').upsert(userSkills);
        }
      }
      
      await fetchProfile(user.id);
    } catch (e) {
      debugPrint('Error creating initial profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('users').upsert({
        ...data,
        'id': user.id,
        'email': user.email,
      });
      
      await fetchProfile(user.id);
    } catch (e) {
      debugPrint('PROFILE UPDATE ERROR: $e');
      rethrow;
    }
  }

  Future<void> updateSkills(List<String> skillNames) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Get/Create skill IDs
      final List<String> skillIds = [];
      for (final name in skillNames) {
        final existing = await supabase.from('skills').select('id').eq('name', name).maybeSingle();
        if (existing != null) {
          skillIds.add(existing['id']);
        } else {
          final created = await supabase.from('skills').insert({'name': name}).select('id').single();
          skillIds.add(created['id']);
        }
      }

      // 2. Sync user_skills
      await supabase.from('user_skills').delete().eq('user_id', user.id);
      if (skillIds.isNotEmpty) {
        await supabase.from('user_skills').insert(skillIds.map((sid) => {
          'user_id': user.id,
          'skill_id': sid,
        }).toList());
      }
      
      await fetchProfile(user.id);
    } catch (e) {
      debugPrint('SKILLS UPDATE ERROR: $e');
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('users').update({
        'onboarding_completed': true,
      }).eq('id', user.id);
      
      // Update state locally for immediate effect
      ref.read(profileStateProvider.notifier).update(ProfileState.complete);
      await fetchProfile(user.id);
    } catch (e) {
      debugPrint('ONBOARDING COMPLETE ERROR: $e');
      rethrow;
    }
  }

}

class AuthService {
  final SupabaseClient client;
  AuthService(this.client);

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> signInWithOtp(String email) async {
    await client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: kIsWeb ? null : 'io.supabase.skillmatch://login-callback',
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await client.auth.verifyOTP(
      token: token,
      type: OtpType.email,
      email: email,
    );
  }

  User? get currentUser => client.auth.currentUser;
}

class SkillMatchUser {
  final String id;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final String role;
  final String? bio;
  final String? course;
  final String? year;
  final List<String> skills;
  final bool openToCollab;
  final bool onboardingCompleted;
  final bool isAdmin;

  SkillMatchUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'CONTRIBUTOR',
    this.bio,
    this.course,
    this.year,
    this.skills = const [],
    this.profileImageUrl,
    this.openToCollab = true,
    this.onboardingCompleted = false,
    this.isAdmin = false,
  });

  factory SkillMatchUser.fromMap(Map<String, dynamic> map) {
    final skillsData = map['user_skills'] as List? ?? [];
    final List<String> parsedSkills = [];
    for (var s in skillsData) {
      if (s is Map && s['skills'] is Map && s['skills']['name'] != null) {
        parsedSkills.add(s['skills']['name'].toString());
      }
    }

    return SkillMatchUser(
      id: (map['id'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'CONTRIBUTOR').toString(),
      bio: map['bio']?.toString(),
      course: map['course']?.toString(),
      year: map['year']?.toString(),
      skills: parsedSkills,
      profileImageUrl: map['avatar_url']?.toString(),
      openToCollab: map['open_to_collab'] ?? true,
      onboardingCompleted: map['onboarding_completed'] ?? false,
      isAdmin: adminEmails.contains((map['email'] ?? '').toString().toLowerCase()) || map['is_admin'] == true,
    );
  }
}
