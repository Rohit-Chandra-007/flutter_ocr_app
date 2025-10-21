import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/setting_section_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/app_info_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSectionCard(
          icon: Icons.palette,
          title: 'Appearance',
          children: [
            ThemeToggleButton(showLabel: true),
          ],
        ),
        SizedBox(height: AppTheme.spacing16),
        SettingSectionCard(
          icon: Icons.info,
          title: 'About',
          children: [
            AppInfoTile(),
          ],
        ),
      ],
    );
  }
}
