import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a small delay to allow the auth state to initialize
    // If auth state doesn't resolve in 3 seconds, we'll let the redirect logic handle it
    // or provide a manual trigger if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Abstract Graphic from Stitch
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Secondary Circle
                    Transform.translate(
                      offset: const Offset(-20, -20),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.ink, width: 2),
                          boxShadow: AppTheme.hardShadow,
                        ),
                      ),
                    ),
                    // Primary Square with Icon
                    Transform.translate(
                      offset: const Offset(20, 20),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          border: Border.all(color: AppTheme.ink, width: 2),
                          boxShadow: AppTheme.hardShadow,
                        ),
                        child: const Icon(
                          Icons.extension,
                          size: 64,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Heading
              Text(
                'SKILLMATCH',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Tilted Sticker Tagline
              Transform.rotate(
                angle: -0.03,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: AppTheme.brutalistDecoration(
                    color: AppTheme.tertiaryContainer,
                  ),
                  child: Text(
                    'CONNECT. CREATE. CONQUER.',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.ink,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),
              // Loading indicator or "DIVE IN" button could go here
              // For now, we use a subtle indicator to show it's working
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
