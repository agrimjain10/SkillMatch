import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class EmailOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const EmailOtpScreen({super.key, required this.email});

  @override
  ConsumerState<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends ConsumerState<EmailOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verify() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).verifyOtp(
        email: widget.email,
        token: _otpController.text.trim(),
      );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('VERIFY ERR: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('VERIFICATION REQUIRED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text('ENTER THE 6-DIGIT CODE SENT TO ${widget.email}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 48),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8),
                decoration: const InputDecoration(counterText: '', hintText: '000000'),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading ? const CircularProgressIndicator() : const Text('AUTHORIZE ACCESS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
