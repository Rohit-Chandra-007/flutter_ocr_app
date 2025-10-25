import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String appVersion;
  final bool isLoading;

  const SettingsState({
    required this.themeMode,
    required this.appVersion,
    this.isLoading = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? appVersion,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      appVersion: appVersion ?? this.appVersion,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
