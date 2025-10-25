import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow/core/theme/app_theme.dart';
import 'package:scanflow/core/providers/theme_provider.dart';
import 'package:scanflow/features/splash/views/widgets/splash_navigation_wrapper.dart';

class ScanFlowApp extends ConsumerWidget {
  const ScanFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeProvider);

    return themeModeAsync.when(
      data: (themeMode) => MaterialApp(
        title: 'ScanFlow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const SplashNavigationWrapper(),
      ),
      loading: () => MaterialApp(
        title: 'ScanFlow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => MaterialApp(
        title: 'ScanFlow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashNavigationWrapper(),
      ),
    );
  }
}
