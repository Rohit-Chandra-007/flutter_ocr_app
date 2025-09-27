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
            ListTile(
              leading: const Icon(Icons.light_mode, color: AppTheme.primaryBlue),
              title: const Text('Light Mode'),
              trailing: currentTheme == ThemeMode.light 
                ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                : null,
              onTap: () {
                themeNotifier.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: AppTheme.primaryBlue),
              title: const Text('Dark Mode'),
              trailing: currentTheme == ThemeMode.dark 
                ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                : null,
              onTap: () {
                themeNotifier.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto, color: AppTheme.primaryBlue),
              title: const Text('System Default'),
              trailing: currentTheme == ThemeMode.system 
                ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                : null,
              onTap: () {
                themeNotifier.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
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