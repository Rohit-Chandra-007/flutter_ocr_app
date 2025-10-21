import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/theme_mode_option.dart';

class ThemeModeTile extends StatelessWidget {
  final ThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeModeTile({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final option = ThemeModeOption.fromMode(mode);

    return ListTile(
      leading: Icon(
        option.icon,
        color: AppTheme.primaryBlue,
      ),
      title: Text(option.label),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
          : null,
      onTap: onTap,
    );
  }
}
