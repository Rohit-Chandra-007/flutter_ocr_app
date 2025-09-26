import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;
  
  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    IconData getIcon() {
      switch (themeMode) {
        case ThemeMode.light:
          return Icons.light_mode;
        case ThemeMode.dark:
          return Icons.dark_mode;
        case ThemeMode.system:
          return Icons.brightness_auto;
      }
    }
    
    String getLabel() {
      switch (themeMode) {
        case ThemeMode.light:
          return 'Light Mode';
        case ThemeMode.dark:
          return 'Dark Mode';
        case ThemeMode.system:
          return 'System';
      }
    }
    
    if (showLabel) {
      return ListTile(
        leading: Icon(
          getIcon(),
          size: iconSize,
          color: AppTheme.primaryBlue,
        ),
        title: Text(getLabel()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeDialog(context, ref),
      );
    }
    
    return IconButton(
      icon: Icon(getIcon(), size: iconSize),
      onPressed: () => _showThemeDialog(context, ref),
      tooltip: 'Change theme',
    );
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = ref.read(themeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Row(
                children: [
                  Icon(Icons.light_mode, color: AppTheme.primaryBlue),
                  SizedBox(width: 12),
                  Text('Light Mode'),
                ],
              ),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Row(
                children: [
                  Icon(Icons.dark_mode, color: AppTheme.primaryBlue),
                  SizedBox(width: 12),
                  Text('Dark Mode'),
                ],
              ),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Row(
                children: [
                  Icon(Icons.brightness_auto, color: AppTheme.primaryBlue),
                  SizedBox(width: 12),
                  Text('System Default'),
                ],
              ),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Simple toggle button that cycles through themes
class SimpleThemeToggle extends ConsumerWidget {
  final double iconSize;
  
  const SimpleThemeToggle({
    super.key,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    IconData getIcon() {
      switch (themeMode) {
        case ThemeMode.light:
          return Icons.light_mode;
        case ThemeMode.dark:
          return Icons.dark_mode;
        case ThemeMode.system:
          return Icons.brightness_auto;
      }
    }
    
    return IconButton(
      icon: Icon(getIcon(), size: iconSize),
      onPressed: () => themeNotifier.toggleTheme(),
      tooltip: 'Toggle theme',
    );
  }
}