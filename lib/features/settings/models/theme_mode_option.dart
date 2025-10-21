import 'package:flutter/material.dart';

class ThemeModeOption {
  final ThemeMode mode;
  final IconData icon;
  final String label;

  const ThemeModeOption({
    required this.mode,
    required this.icon,
    required this.label,
  });

  static const List<ThemeModeOption> all = [
    ThemeModeOption(
      mode: ThemeMode.light,
      icon: Icons.light_mode,
      label: 'Light Mode',
    ),
    ThemeModeOption(
      mode: ThemeMode.dark,
      icon: Icons.dark_mode,
      label: 'Dark Mode',
    ),
    ThemeModeOption(
      mode: ThemeMode.system,
      icon: Icons.brightness_auto,
      label: 'System Default',
    ),
  ];

  static ThemeModeOption fromMode(ThemeMode mode) {
    return all.firstWhere((option) => option.mode == mode);
  }
}
