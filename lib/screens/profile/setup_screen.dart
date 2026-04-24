import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _prefilled = false;

  // Form Fields
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedRole = 'STUDENT';
  String _selectedYear = 'YEAR 1';
  final List<String> _selectedSkills = [];

  final List<String> _roles = [
    'STUDENT',
    'RESEARCHER',
    'DEVELOPER',
    'DESIGNER',
    'PROFESSOR',
  ];
  final List<String> _years = [
    'YEAR 1',
    'YEAR 2',
    'YEAR 3',
    'YEAR 4',
    'POSTGRAD',
    'PHD',
  ];
  final List<String> _commonSkills = [
    'FLUTTER',
    'PYTHON',
    'REACT',
    'UI DESIGN',
    'NODE.JS',
    'SQL',
    'DEVOPS',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _prefill(SkillMatchUser user) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = user.fullName;
    _courseController.text = user.course ?? '';
    _bioController.text = user.bio ?? '';
    final role = user.role.toUpperCase();
    final year = (user.year ?? '').toUpperCase();
    if (_roles.contains(role)) _selectedRole = role;
    if (_years.contains(year)) _selectedYear = year;
    _selectedSkills
      ..clear()
      ..addAll(user.skills.map((skill) => skill.toUpperCase()));
  }

  void _nextPage() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _handleSave();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IDENTIFICATION NAME REQUIRED')),
      );
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(userProvider.notifier);
      await notifier.updateProfile({
        'full_name': _nameController.text.trim(),
        'role': _selectedRole,
        'course': _courseController.text.trim(),
        'year': _selectedYear,
        'bio': _bioController.text.trim(),
        'onboarding_completed': true,
      });
      await notifier.updateSkills(_selectedSkills);

      if (mounted) context.go('/profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PROFILE UPDATE ERROR: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    if (currentUser != null && !_prefilled) {
      _prefill(currentUser);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GridBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              padding: const EdgeInsets.all(40),
              decoration: AppTheme.brutalistDecoration(
                color: AppTheme.surfaceContainer,
                radius: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP ${_currentStep + 1} / 3',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProgressIndicator(),
                  const SizedBox(height: 40),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey(_currentStep),
                      child: _currentStep == 0
                          ? _buildStep1()
                          : _currentStep == 1
                          ? _buildStep2()
                          : _buildStep3(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _previousPage,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.ink,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'BACK',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentStep == 2
                                      ? 'SAVE PROFILE'
                                      : 'NEXT STEP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    String label = 'IDENTITY';
    if (_currentStep == 1) label = 'ACADEMIC';
    if (_currentStep == 2) label = 'SKILLS';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        border: Border.all(color: AppTheme.ink, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryContainer : Colors.white,
              border: Border.all(color: AppTheme.ink, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading('IDENTIFICATION', 'Establish your primary identity.'),
        const SizedBox(height: 32),
        _buildLabel('FULL NAME'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'ENTER YOUR NAME...'),
        ),
        const SizedBox(height: 24),
        _buildLabel('PRIMARY ROLE'),
        const SizedBox(height: 8),
        _buildBrutalistDropdown(
          value: _selectedRole,
          items: _roles,
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading('ACADEMIC STATUS', 'Define your current standing.'),
        const SizedBox(height: 32),
        _buildLabel('COURSE / MAJOR'),
        const SizedBox(height: 8),
        TextField(
          controller: _courseController,
          decoration: const InputDecoration(
            hintText: 'E.G. COMPUTER SCIENCE...',
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('YEAR OF STUDY'),
        const SizedBox(height: 8),
        _buildBrutalistDropdown(
          value: _selectedYear,
          items: _years,
          onChanged: (v) => setState(() => _selectedYear = v!),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading('SKILL MATRIX', 'What value do you bring?'),
        const SizedBox(height: 24),
        _buildLabel('BIOGRAPHY'),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'TELL THE ARCHIVE ABOUT YOURSELF...',
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('SKILLS (SELECT MULTIPLE)'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonSkills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSkills.remove(skill);
                  } else {
                    _selectedSkills.add(skill);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.tertiaryContainer : Colors.white,
                  border: Border.all(color: AppTheme.ink, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isSelected
                      ? []
                      : [
                          const BoxShadow(
                            color: AppTheme.ink,
                            offset: Offset(2, 2),
                          ),
                        ],
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeading(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildBrutalistDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.brutalistDecoration(color: Colors.white),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    r,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
