import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpSent = false;

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER YOUR UNIVERSITY EMAIL')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      
      if (!_isOtpSent) {
        await authService.signInWithOtp(_emailController.text.trim());
        setState(() => _isOtpSent = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ACCESS CODE SENT TO ARCHIVE EMAIL')),
          );
        }
      } else {
        if (_otpController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PLEASE ENTER THE 6-DIGIT CODE')),
          );
          return;
        }
        await authService.verifyOtp(
          email: _emailController.text.trim(),
          token: _otpController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TRANSMISSION ERROR: ${e.toString().toUpperCase()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GridBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 40, color: AppTheme.ink),
                    const SizedBox(width: 12),
                    Text(
                      'SkillMatch',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.brutalistDecoration(
                    color: AppTheme.surfaceContainer,
                    radius: 12,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOtpSent ? 'VERIFY CODE' : 'WELCOME BACK',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ink,
                              letterSpacing: -1.0,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isOtpSent 
                                ? 'Enter the code sent to your email.'
                                : 'Access the academic archive.',
                            style: GoogleFonts.inter(
                              color: AppTheme.ink.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          if (!_isOtpSent) ...[
                            _buildLabel('UNIVERSITY EMAIL'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'student@university.edu',
                              ),
                            ),
                          ] else ...[
                            _buildLabel('6-DIGIT ACCESS CODE'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '123456',
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryContainer,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    height: 20, 
                                    width: 20, 
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.ink)),
                                  )
                                : Text(_isOtpSent ? 'VERIFY ACCESS' : 'SEND CODE'),
                            ),
                          ),
                          
                          if (_isOtpSent)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _isOtpSent = false;
                                    _otpController.clear();
                                  }),
                                  child: Text(
                                    'CHANGE EMAIL',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Positioned(
                        top: -45,
                        right: -15,
                        child: Transform.rotate(
                          angle: 0.08,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.tertiaryContainer,
                              border: Border.all(color: AppTheme.ink, width: 2),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(2, 2))],
                            ),
                            child: const Text(
                              'BETA ACCESS',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: AppTheme.ink,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    '© 2026 ACADEMIC ARCHIVE SYSTEM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1.5,
        color: AppTheme.ink,
      ),
    );
  }
}
