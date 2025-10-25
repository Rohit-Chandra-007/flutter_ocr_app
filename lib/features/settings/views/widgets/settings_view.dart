import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow/core/constants/app_constants.dart';
import 'package:scanflow/core/utils/bottom_sheet_utils.dart';
import 'package:scanflow/core/utils/snackbar_utils.dart';
import 'package:scanflow/core/widgets/app_info_card.dart';
import 'package:scanflow/features/settings/views/widgets/setting_tile.dart';

import '../../../../core/extensions/theme_mode_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../viewmodels/settings_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Theme Setting
          SettingTile(
            icon: settingsState.themeMode.icon,
            iconColor: AppTheme.primaryBlue,
            title: 'Theme',
            subtitle: settingsState.themeMode.label,
            onTap: () => BottomSheetUtils.showThemeDialog(context, ref),
          ),

          const SizedBox(height: 12),

          // Divider
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),

          const SizedBox(height: 12),

          // App Info
          SettingTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppTheme.accentTeal,
            title: 'About',
            subtitle: 'Version ${settingsState.appVersion}',
            onTap: () => SnackbarUtils.showAboutDialog(context),
          ),

          const SizedBox(height: 24),

          // App Card
          const AppInfoCard(),
        ],
      ),
    );
  }
}
