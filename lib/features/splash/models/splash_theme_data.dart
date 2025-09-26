import 'package:flutter/material.dart';

/// Theme data model for splash screen color extraction and theme integration
class SplashThemeData {
  final Color backgroundColor;
  final Color logoColor;
  final Color scannerColor;
  final Color textColor;
  final Color glowColor;

  const SplashThemeData({
    required this.backgroundColor,
    required this.logoColor,
    required this.scannerColor,
    required this.textColor,
    required this.glowColor,
  });

  /// Extract appropriate colors from current theme for splash screen
  factory SplashThemeData.fromTheme(ThemeData theme, {bool highContrast = false}) {
    final isDark = theme.brightness == Brightness.dark;
    
    // Adjust colors for high contrast mode
    if (highContrast) {
      return SplashThemeData(
        backgroundColor: isDark ? Colors.black : Colors.white,
        logoColor: isDark ? Colors.white : Colors.black,
        scannerColor: isDark ? Colors.white : Colors.black,
        textColor: isDark ? Colors.white : Colors.black,
        glowColor: isDark 
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.5),
      );
    }
    
    return SplashThemeData(
      backgroundColor: theme.scaffoldBackgroundColor,
      logoColor: theme.colorScheme.primary,
      scannerColor: theme.colorScheme.secondary,
      textColor: theme.colorScheme.onSurface,
      glowColor: isDark 
          ? theme.colorScheme.secondary.withValues(alpha: 0.3)
          : theme.colorScheme.secondary.withValues(alpha: 0.2),
    );
  }

  /// Create a copy with modified properties
  SplashThemeData copyWith({
    Color? backgroundColor,
    Color? logoColor,
    Color? scannerColor,
    Color? textColor,
    Color? glowColor,
  }) {
    return SplashThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      logoColor: logoColor ?? this.logoColor,
      scannerColor: scannerColor ?? this.scannerColor,
      textColor: textColor ?? this.textColor,
      glowColor: glowColor ?? this.glowColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SplashThemeData &&
        other.backgroundColor == backgroundColor &&
        other.logoColor == logoColor &&
        other.scannerColor == scannerColor &&
        other.textColor == textColor &&
        other.glowColor == glowColor;
  }

  @override
  int get hashCode {
    return backgroundColor.hashCode ^
        logoColor.hashCode ^
        scannerColor.hashCode ^
        textColor.hashCode ^
        glowColor.hashCode;
  }
}