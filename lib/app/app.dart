import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/splash/splash.dart';
import '../features/settings/providers/theme_provider.dart';
import 'theme/app_theme.dart';

class ScanFlowApp extends ConsumerWidget {
  const ScanFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'ScanFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
