import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../widgets/theme_toggle_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // Theme Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const ThemeToggleButton(showLabel: true),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // App Info Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.document_scanner, color: AppTheme.primaryBlue),
                  title: const Text('ScanFlow'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ScanFlow',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.document_scanner,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'A beautiful, modern OCR mobile application with seamless user experience.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Transform your device into a powerful document scanner with intelligent text recognition.',
        ),
      ],
    );
  }
}