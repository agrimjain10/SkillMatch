import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme());
final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class AppTheme {
  // Static access for constants
  static const Color terracotta = primaryContainer;
  static const Color lavender = secondaryContainer;
  static const Color lemonLime = tertiaryContainer;
  static const Color cream = background;

  TextStyle get bodyStyle => GoogleFonts.inter(
    color: ink,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  // Branding Constants
  static const Color primary = Color(0xFFA7391E);
  static const Color primaryContainer = Color(0xFFFF7A59); // Terracotta
  static const Color secondary = Color(0xFF5D5794);
  static const Color secondaryContainer = Color(0xFFC1B9FE); // Lavender
  static const Color tertiary = Color(0xFF526600);
  static const Color tertiaryContainer = Color(0xFFD4F75B); // Lemon-Lime
  static const Color ink = Color(0xFF1C1C1A); // Near-Black
  static const Color background = Color(0xFFFCF9F6); // Cream Canvas
  static const Color surface = Color(0xFFFCF9F6);
  static const Color surfaceContainer = Color(0xFFF0EDEA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFBA1A1A);

  // Typography styles commonly used
  TextStyle get headingStyle => GoogleFonts.spaceGrotesk(
    color: ink,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  // Hard Shadow configuration
  static const List<BoxShadow> hardShadow = [
    BoxShadow(color: ink, offset: Offset(4, 4), blurRadius: 0),
  ];

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primary,
            primary: primary,
            primaryContainer: primaryContainer,
            secondary: secondary,
            secondaryContainer: secondaryContainer,
            tertiary: tertiary,
            tertiaryContainer: tertiaryContainer,
            surface: surface,
            error: error,
            onPrimary: Colors.white,
            onSecondary: ink,
            onTertiary: ink,
            onSurface: ink,
            outline: ink,
          ).copyWith(
            surfaceContainer: surfaceContainer,
            surfaceContainerLowest: surfaceContainerLowest,
          ),
      scaffoldBackgroundColor: background,

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: ink,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: ink,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          color: ink,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          color: ink,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: ink,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          color: ink,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(color: ink, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: ink, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.inter(color: ink, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: ink, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.inter(
          color: ink,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(color: ink, fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.inter(
          color: ink,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.inter(
          color: ink,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: ink,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: primaryContainer,
              foregroundColor: ink,
              textStyle: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: ink, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(ink.withValues(alpha: 0.1)),
            ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ink, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ink, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
        labelStyle: GoogleFonts.inter(
          color: ink.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkThemeData {
    final base = themeData;
    const darkSurface = Color(0xFF171717);
    const darkCard = Color(0xFF242424);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkSurface,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: darkSurface,
        surfaceContainer: darkCard,
        surfaceContainerLowest: darkCard,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: darkCard,
        labelStyle: GoogleFonts.inter(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helpers
  static BoxDecoration brutalistDecoration({Color? color, double radius = 6}) {
    return BoxDecoration(
      color: color ?? surfaceContainerLowest,
      border: Border.all(color: ink, width: 2),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: hardShadow,
    );
  }

  // Sticker rotation helper
  static Widget sticker({required Widget child, double angle = 0.05}) {
    return Transform.rotate(angle: angle, child: child);
  }
}

// Background Grid Painter
class DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.ink.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotSize = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridBackground extends StatelessWidget {
  final Widget child;
  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? const Color(0xFF171717) : AppTheme.background,
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: DottedGridPainter())),
        child,
      ],
    );
  }
}
