import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class SuccessScreen extends StatelessWidget {
  final String message;
  final String? nextRoute;
  const SuccessScreen({super.key, required this.message, this.nextRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 100, color: AppTheme.primaryContainer),
                const SizedBox(height: 32),
                const Text('OPERATION SUCCESSFUL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                const SizedBox(height: 16),
                Text(message.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: () => context.go(nextRoute ?? '/home'),
                  child: const Text('CONTINUE MISSION'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
