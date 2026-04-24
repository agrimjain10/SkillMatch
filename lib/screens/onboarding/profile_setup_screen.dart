import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    if (user != null) {
      _nameController.text = user.fullName;
      _roleController.text = user.role;
    }
  }

  Future<void> _next() async {
    if (_nameController.text.isEmpty || _roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE COMPLETE ALL FIELDS')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).updateProfile({
        'full_name': _nameController.text.trim(),
        'role': _roleController.text.trim(),
        'year': _yearController.text.trim(),
      });
      if (mounted) context.push('/setup/bio');
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
        title: const Text('STEP 1: IDENTITY', style: TextStyle(letterSpacing: 4)),
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
                'ESTABLISH YOUR DIGITAL PRESENCE.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'FULL NAME (OPERATIVE ID)'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'PRIMARY ROLE (E.G. DEVELOPER, DESIGNER)'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'ACADEMIC YEAR'),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: _isLoading ? null : _next,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('PROCEED TO BIO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
