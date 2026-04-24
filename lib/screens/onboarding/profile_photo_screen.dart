import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supabase_provider.dart';

class ProfilePhotoScreen extends ConsumerStatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  bool _isLoading = false;
  XFile? _selectedImage;

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1200);
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _next() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(userProvider);
      var avatarUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=${user?.email ?? 'default'}';

      if (_selectedImage != null) {
        try {
          final supabase = ref.read(supabaseClientProvider);
          final bytes = await _selectedImage!.readAsBytes();
          final path = '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
          avatarUrl = supabase.storage.from('avatars').getPublicUrl(path);
        } catch (_) {
          avatarUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=${user?.email ?? 'default'}';
        }
      }

      await ref.read(userProvider.notifier).updateProfile({
        'avatar_url': avatarUrl,
      });
      if (mounted) context.push('/setup/skills');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('UPDATE ERR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STEP 3: VISUAL', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'VISUAL ENCODING.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 48),
              Center(
                child: InkWell(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: AppTheme.brutalistDecoration(color: AppTheme.surfaceContainerLowest),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_selectedImage == null ? Icons.add_a_photo : Icons.check_circle, size: 64),
                        const SizedBox(height: 12),
                        Text(
                          _selectedImage == null ? 'TAP TO SELECT' : 'PHOTO READY',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: _isLoading ? null : _next,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('UPLOAD & PROCEED'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/setup/skills'),
                child: const Text('SKIP FOR NOW'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
