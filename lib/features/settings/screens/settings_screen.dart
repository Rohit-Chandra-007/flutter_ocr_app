import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../views/settings_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: const [
          SettingsView(),
        ],
      ),
    );
  }
}