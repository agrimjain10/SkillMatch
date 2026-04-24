import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/chat_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(discoverProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DISCOVER TALENT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ARCHIVE SEARCH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'SEARCH BY SKILL, ROLE, OR NAME...',
                  suffixIcon: IconButton(
                    tooltip: 'Advanced search',
                    onPressed: () => context.push('/search/advanced'),
                    icon: const Icon(Icons.tune),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: profilesAsync.when(
                  data: (profiles) {
                    final filtered = profiles.where((profile) {
                      if (_query.isEmpty) return true;
                      final skills = (profile['user_skills'] as List? ?? [])
                          .map(
                            (item) => (item is Map && item['skills'] is Map)
                                ? (item['skills'] as Map)['name']
                                : null,
                          )
                          .whereType<Object>()
                          .join(' ');
                      final haystack =
                          '${profile['full_name']} ${profile['role']} ${profile['bio']} $skills'
                              .toLowerCase();
                      return haystack.contains(_query);
                    }).toList();
                    if (filtered.isEmpty) return const _DiscoverEmptyState();
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _TalentCard(index: index, profile: filtered[index]),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.ink),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('DISCOVERY LOAD FAILED: $error'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TalentCard extends ConsumerStatefulWidget {
  final int index;
  final Map<String, dynamic>? profile;
  const _TalentCard({required this.index, this.profile});

  @override
  ConsumerState<_TalentCard> createState() => _TalentCardState();
}

class _TalentCardState extends ConsumerState<_TalentCard> {
  bool _isMatching = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final index = widget.index;
    final skills = (profile?['user_skills'] as List? ?? [])
        .map(
          (item) => (item is Map && item['skills'] is Map)
              ? (item['skills'] as Map)['name']
              : null,
        )
        .whereType<Object>()
        .map((item) => item.toString().toUpperCase())
        .take(4)
        .toList();
    final visibleSkills = skills;
    final name = (profile?['full_name'] ?? 'UNKNOWN USER')
        .toString()
        .toUpperCase();
    final role = (profile?['role'] ?? 'ROLE NOT SET').toString().toUpperCase();
    final bio = (profile?['bio'] ?? 'NO BIO PROVIDED.')
        .toString()
        .toUpperCase();
    final userId = profile?['id']?.toString();
    final isIncoming = profile?['incoming_match_id'] != null;

    return AnimatedScale(
          scale: _isMatching ? 0.98 : 1,
          duration: 120.ms,
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.brutalistDecoration(
              color: index % 2 == 0
                  ? AppTheme.secondaryContainer
                  : AppTheme.tertiaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.ink,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            role,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  bio,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: visibleSkills
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            border: Border.all(color: AppTheme.ink, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: userId == null || _isMatching
                            ? null
                            : () async {
                                setState(() => _isMatching = true);
                                try {
                                  final result = await ref
                                      .read(chatServiceProvider)
                                      .requestMatch(userId);
                                  if (!context.mounted) return;
                                  if (result != 'pending' &&
                                      result != 'ignored') {
                                    context.push(
                                      '/match-celebration?matchId=$result',
                                      extra: profile,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '$name ADDED TO CHATS. WAITING FOR MUTUAL MATCH.',
                                        ),
                                      ),
                                    );
                                  }
                                  ref.invalidate(discoverProfilesProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('MATCH FAILED: $e'),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isMatching = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ink,
                          foregroundColor: Colors.white,
                        ),
                        child: _isMatching
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isIncoming ? 'MATCH BACK' : 'MATCH'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: AppTheme.brutalistDecoration(
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: userId == null
                            ? null
                            : () => context.push('/user/$userId'),
                        icon: const Icon(Icons.person_search),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 180.ms)
        .slideY(begin: 0.06, duration: 220.ms, curve: Curves.easeOutCubic);
  }
}

class _DiscoverEmptyState extends StatelessWidget {
  const _DiscoverEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: AppTheme.brutalistDecoration(
          color: AppTheme.tertiaryContainer,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 52),
            SizedBox(height: 16),
            Text(
              'NO MATCHING DOSSIERS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'TRY A DIFFERENT SKILL, ROLE, OR NAME.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
