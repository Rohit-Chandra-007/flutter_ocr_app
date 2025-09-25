import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database
  await DatabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: ScanFlowApp(),
    ),
  );
}
