import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow/core/theme/app_theme.dart';
import 'package:scanflow/core/providers/theme_provider.dart';
import 'features/splash/splash.dart';

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
    );
  }
}
