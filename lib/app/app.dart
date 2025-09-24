import 'package:flutter/material.dart';
import '../features/ocr/screens/ocr_screen.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart OCR Scanner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const OCRScreen(),
    );
  }
}