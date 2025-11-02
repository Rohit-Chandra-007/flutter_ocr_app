import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  SettingsState build() {
    final themeModeAsync = ref.watch(themeProvider);

    return SettingsState(
      themeMode: themeModeAsync.value ?? ThemeMode.system,
      appVersion: AppConstants.kAppVersion,
      isLoading: themeModeAsync.isLoading,
    );
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    await ref.read(themeProvider.notifier).setThemeMode(themeMode);
  }
}
