import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gstupuqwueglaturddmq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzdHVwdXF3dWVnbGF0dXJkZG1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3NTMxOTMsImV4cCI6MjA5MjMyOTE5M30.U8VuQwGH1NyFh9g6OLQ5XuWo72HVbfF4YdLCG6G5bUc',
  );

  runApp(const ProviderScope(child: SkillMatchApp()));
}

class SkillMatchApp extends ConsumerWidget {
  const SkillMatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'SkillMatch',
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
