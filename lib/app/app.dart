import 'package:flutter/material.dart';
import '../features/splash/splash.dart';
import 'theme/app_theme.dart';

class ScanFlowApp extends StatelessWidget {
  const ScanFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
