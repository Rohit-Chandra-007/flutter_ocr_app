import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/theme_mode_option.dart';

part 'theme_viewmodel.g.dart';

@riverpod
class ThemeViewModel extends _$ThemeViewModel {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme([ThemeMode? mode]) {
    if (mode != null) {
      state = mode;
      return;
    }

    switch (state) {
      case ThemeMode.light:
        state = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        state = ThemeMode.light;
        break;
      case ThemeMode.system:
        state = ThemeMode.light;
        break;
    }
  }

  ThemeModeOption get currentOption => ThemeModeOption.fromMode(state);

  bool isSelected(ThemeMode mode) => state == mode;

  List<ThemeModeOption> get availableOptions => ThemeModeOption.all;
}
