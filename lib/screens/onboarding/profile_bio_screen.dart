import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileBioScreen extends ConsumerStatefulWidget {
  const ProfileBioScreen({super.key});

  @override
  ConsumerState<ProfileBioScreen> createState() => _ProfileBioScreenState();
}

class _ProfileBioScreenState extends ConsumerState<ProfileBioScreen> {
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    if (user != null) {
      _bioController.text = user.bio ?? '';
    }
  }

  Future<void> _next() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).updateProfile({
        'bio': _bioController.text.trim(),
      });
      if (mounted) context.push('/setup/photo');
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
        title: const Text('STEP 2: BIOGRAPHY', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'NARRATE YOUR ORIGIN STORY.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'KEEP IT BRIEF, IMPACTFUL, AND AUTHENTIC.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _bioController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'BIOGRAPHY',
                  hintText: 'I BUILD SYSTEMS THAT DEFY GRAVITY...',
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: _isLoading ? null : _next,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('PROCEED TO PHOTO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
