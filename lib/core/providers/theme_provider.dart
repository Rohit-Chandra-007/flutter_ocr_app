import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/theme_service.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  final _themeService = ThemeService();

  @override
  Future<ThemeMode> build() async {
    return await _themeService.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _themeService.saveThemeMode(mode);
    state = AsyncValue.data(mode);
  }

  Future<void> toggleTheme([ThemeMode? mode]) async {
    if (mode != null) {
      await setThemeMode(mode);
      return;
    }

    final currentMode = state.value ?? ThemeMode.system;
    final newMode = switch (currentMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    };
    
    await setThemeMode(newMode);
  }
}
