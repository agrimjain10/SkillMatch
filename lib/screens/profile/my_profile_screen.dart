import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supabase_provider.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final stats =
        ref.watch(userStatsProvider).value ??
        {'projects': 0, 'matches': 0, 'xp': 0};

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'USER DOSSIER',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 32),
              _buildStatsRow(stats),
              const SizedBox(height: 48),
              _buildSectionTitle('CORE COMPETENCIES'),
              const SizedBox(height: 16),
              _buildSkillsWrap(user?.skills ?? []),
              const SizedBox(height: 48),
              _buildSectionTitle('BIOGRAPHY'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.brutalistDecoration(),
                child: Text(
                  user?.bio ?? 'NO BIOGRAPHICAL DATA FOUND IN ARCHIVE.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.push('/profile/edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryContainer,
                ),
                child: const Text('EDIT PROFILE DATA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(SkillMatchUser? user) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: AppTheme.brutalistDecoration(
            color: AppTheme.surfaceContainerLowest,
            radius: 60,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: user?.profileImageUrl != null
                ? Image.network(user!.profileImageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 64),
          ),
        ),
        const SizedBox(height: 24),
        const _AvatarUploadButton(),
        const SizedBox(height: 16),
        Text(
          user?.fullName.toUpperCase() ?? 'IDENTIFICATION PENDING',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          user?.role.toUpperCase() ?? 'NO ROLE ASSIGNED',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          _buildStatItem('PROJECTS', '${stats['projects'] ?? 0}'),
          _buildStatItem('MATCHES', '${stats['matches'] ?? 0}'),
          _buildStatItem('XP', '${stats['xp'] ?? 0}'),
        ];
        if (constraints.maxWidth < 360) {
          return Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: item,
                  ),
                )
                .toList(),
          );
        }
        return Row(children: items);
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.brutalistDecoration(),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSkillsWrap(List<String> skills) {
    if (skills.isEmpty) return const Text('NO SKILLS LOGGED.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
          .map(
            (s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: AppTheme.brutalistDecoration(
                color: AppTheme.tertiaryContainer,
              ),
              child: Text(
                s,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AvatarUploadButton extends ConsumerStatefulWidget {
  const _AvatarUploadButton();

  @override
  ConsumerState<_AvatarUploadButton> createState() =>
      _AvatarUploadButtonState();
}

class _AvatarUploadButtonState extends ConsumerState<_AvatarUploadButton> {
  bool _uploading = false;

  Future<void> _changePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (image == null) return;
    setState(() => _uploading = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final bytes = await image.readAsBytes();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${user.id}/profile_$stamp.jpg';
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      final url =
          '${supabase.storage.from('avatars').getPublicUrl(path)}?v=$stamp';
      await ref.read(userProvider.notifier).updateProfile({'avatar_url': url});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PROFILE PHOTO UPDATED')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PHOTO UPDATE FAILED: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _uploading ? null : _changePhoto,
      icon: _uploading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.photo_camera),
      label: const Text('CHANGE PHOTO'),
    );
  }
}
