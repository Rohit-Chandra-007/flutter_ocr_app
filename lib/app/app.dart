import 'package:flutter/material.dart';
import '../features/scan_history/screens/home_screen.dart';
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
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
