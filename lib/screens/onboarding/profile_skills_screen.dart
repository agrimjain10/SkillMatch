import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileSkillsScreen extends ConsumerStatefulWidget {
  const ProfileSkillsScreen({super.key});

  @override
  ConsumerState<ProfileSkillsScreen> createState() => _ProfileSkillsScreenState();
}

class _ProfileSkillsScreenState extends ConsumerState<ProfileSkillsScreen> {
  final List<String> _selectedSkills = [];
  final List<String> _availableSkills = [
    'FLUTTER', 'DART', 'SUPABASE', 'UI DESIGN', 'PYTHON', 
    'REACT', 'NODE.JS', 'POSTGRES', 'MACHINE LEARNING', 'DEVOPS'
  ];
  bool _isLoading = false;

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  Future<void> _next() async {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SELECT AT LEAST ONE SKILL')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).updateSkills(_selectedSkills);
      if (mounted) context.push('/onboarding-quiz');
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
        title: const Text('STEP 4: CAPABILITIES', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'DEFINE YOUR ARSENAL.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'SELECT THE CORE COMPETENCIES YOU BRING TO THE SYSTEM.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableSkills.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return InkWell(
                      onTap: () => _toggleSkill(skill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: AppTheme.brutalistDecoration(
                          color: isSelected ? AppTheme.primaryContainer : AppTheme.surfaceContainerLowest,
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _next,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('PROCEED TO PSYCH EVAL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
