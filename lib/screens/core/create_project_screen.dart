import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/supabase_provider.dart';
import '../../providers/project_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Design';
  bool _isSubmitting = false;

  final List<String> _categories = ['Design', 'Development', 'Research', 'Marketing', 'Business'];

  Future<void> _createProject() async {
    if (_titleController.text.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      
      if (user == null) throw 'Authentication required';

      await supabase.from('projects').insert({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'created_by': user.id,
        'status': 'open',
      });

      ref.invalidate(allProjectsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PROJECT ARCHIVE INITIATED SUCCESSFULLY')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FAILURE: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: const Text('INITIATE ARCHIVE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROJECT IDENTIFIER', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. SKILLMATCH 2.0'),
              ),
              const SizedBox(height: 24),
              Text('PROJECT DOSSIER / DESCRIPTION', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'DESCRIBE THE COLLABORATION OBJECTIVES...'),
              ),
              const SizedBox(height: 24),
              Text('CLASSIFICATION', style: theme.textTheme.labelSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: AppTheme.brutalistDecoration(
                        color: isSelected ? AppTheme.tertiaryContainer : Colors.white,
                      ),
                      child: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.ink : AppTheme.ink.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _createProject,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  backgroundColor: AppTheme.primaryContainer,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: AppTheme.ink)
                    : const Text('COMMIT TO ARCHIVES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
