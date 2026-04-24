import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_profile_provider.dart';

class UserProfilePublicScreen extends ConsumerWidget {
  final String userId;
  const UserProfilePublicScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicUserProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('DOSSIER VIEW'), backgroundColor: Colors.transparent, elevation: 0),
      body: GridBackground(
        child: profileAsync.when(
          data: (profile) => _ProfileBody(profile: profile),
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.ink)),
          error: (_, _) => const _ProfileBody(profile: null),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final skills = (profile?['user_skills'] as List? ?? [])
        .map((item) => (item is Map && item['skills'] is Map) ? (item['skills'] as Map)['name'] : null)
        .whereType<Object>()
        .map((item) => item.toString().toUpperCase())
        .toList();
    final visibleSkills = skills;
    final name = (profile?['full_name'] ?? 'ANONYMOUS USER').toString().toUpperCase();
    final role = (profile?['role'] ?? 'ROLE NOT SET').toString().toUpperCase();
    final bio = (profile?['bio'] ?? 'OPEN TO CAMPUS COLLABORATION.').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: AppTheme.brutalistDecoration(color: AppTheme.primaryContainer),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: AppTheme.ink, child: Icon(Icons.person, color: Colors.white, size: 40)),
                const SizedBox(height: 16),
                Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                Text(role, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.brutalistDecoration(color: Colors.white),
            child: Text(bio, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          const Text('VERIFIED SKILLS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 12),
          if (visibleSkills.isEmpty)
            const Text('NO SKILLS LOGGED.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visibleSkills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.brutalistDecoration(color: Colors.white),
                child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              )).toList(),
            ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('COLLABORATION PROPOSAL PREPARED')),
            ),
            child: const Text('PROPOSE COLLABORATION'),
          ),
        ],
      ),
    );
  }
}
