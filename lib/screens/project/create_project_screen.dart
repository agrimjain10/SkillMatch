import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/project_provider.dart';
import '../../providers/supabase_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isInitializing = false;

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isInitializing = true);
    try {
      final user = ref.read(supabaseClientProvider).auth.currentUser;
      if (user == null) return;

      await ref.read(projectServiceProvider).createProject({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'created_by': user.id,
        'status': 'active',
      });

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('INITIALIZATION FAILURE: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('NEW ARCHIVE ENTRY', style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'PROJECT TITLE'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'OBJECTIVE DESCRIPTION'),
                maxLines: 5,
              ),
              const SizedBox(height: 40),
              AppTheme.sticker(
                angle: 0.01,
                child: InkWell(
                  onTap: _isInitializing ? null : _submit,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.brutalistDecoration(
                      color: _isInitializing ? AppTheme.ink.withValues(alpha: 0.2) : AppTheme.primaryContainer,
                    ),
                    child: Center(
                      child: _isInitializing
                          ? const CircularProgressIndicator(color: AppTheme.ink)
                          : const Text(
                              'CONFIRM INITIALIZATION',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink),
                            ),
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
