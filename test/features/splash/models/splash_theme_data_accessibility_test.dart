import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/models/splash_theme_data.dart';

void main() {
  group('SplashThemeData Accessibility', () {
    test('should create normal theme data from light theme', () {
      // Arrange
      final lightTheme = ThemeData.light();

      // Act
      final themeData = SplashThemeData.fromTheme(lightTheme);

      // Assert
      expect(themeData.backgroundColor, lightTheme.scaffoldBackgroundColor);
      expect(themeData.logoColor, lightTheme.colorScheme.primary);
      expect(themeData.scannerColor, lightTheme.colorScheme.secondary);
      expect(themeData.textColor, lightTheme.colorScheme.onSurface);
      expect(themeData.glowColor, isNotNull);
    });

    test('should create normal theme data from dark theme', () {
      // Arrange
      final darkTheme = ThemeData.dark();

      // Act
      final themeData = SplashThemeData.fromTheme(darkTheme);

      // Assert
      expect(themeData.backgroundColor, darkTheme.scaffoldBackgroundColor);
      expect(themeData.logoColor, darkTheme.colorScheme.primary);
      expect(themeData.scannerColor, darkTheme.colorScheme.secondary);
      expect(themeData.textColor, darkTheme.colorScheme.onSurface);
      expect(themeData.glowColor, isNotNull);
    });

    test('should create high contrast theme data from light theme', () {
      // Arrange
      final lightTheme = ThemeData.light();

      // Act
      final themeData = SplashThemeData.fromTheme(lightTheme, highContrast: true);

      // Assert - High contrast should use pure black/white
      expect(themeData.backgroundColor, Colors.white);
      expect(themeData.logoColor, Colors.black);
      expect(themeData.scannerColor, Colors.black);
      expect(themeData.textColor, Colors.black);
      expect(themeData.glowColor.value, Colors.black.withValues(alpha: 0.5).value);
    });

    test('should create high contrast theme data from dark theme', () {
      // Arrange
      final darkTheme = ThemeData.dark();

      // Act
      final themeData = SplashThemeData.fromTheme(darkTheme, highContrast: true);

      // Assert - High contrast should use pure black/white
      expect(themeData.backgroundColor, Colors.black);
      expect(themeData.logoColor, Colors.white);
      expect(themeData.scannerColor, Colors.white);
      expect(themeData.textColor, Colors.white);
      expect(themeData.glowColor.value, Colors.white.withValues(alpha: 0.5).value);
    });

    test('should have different colors for normal vs high contrast', () {
      // Arrange
      final theme = ThemeData.light();

      // Act
      final normalTheme = SplashThemeData.fromTheme(theme, highContrast: false);
      final highContrastTheme = SplashThemeData.fromTheme(theme, highContrast: true);

      // Assert - Colors should be different
      expect(normalTheme.backgroundColor, isNot(equals(highContrastTheme.backgroundColor)));
      expect(normalTheme.logoColor, isNot(equals(highContrastTheme.logoColor)));
      expect(normalTheme.scannerColor, isNot(equals(highContrastTheme.scannerColor)));
      expect(normalTheme.textColor, isNot(equals(highContrastTheme.textColor)));
    });

    test('should provide high contrast colors with better visibility', () {
      // Arrange
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      // Act
      final lightHighContrast = SplashThemeData.fromTheme(lightTheme, highContrast: true);
      final darkHighContrast = SplashThemeData.fromTheme(darkTheme, highContrast: true);

      // Assert - High contrast should use pure colors for maximum contrast
      expect(lightHighContrast.backgroundColor, Colors.white);
      expect(lightHighContrast.textColor, Colors.black);
      expect(darkHighContrast.backgroundColor, Colors.black);
      expect(darkHighContrast.textColor, Colors.white);
    });

    test('should maintain theme consistency between light and dark modes', () {
      // Arrange
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      // Act
      final lightNormal = SplashThemeData.fromTheme(lightTheme, highContrast: false);
      final darkNormal = SplashThemeData.fromTheme(darkTheme, highContrast: false);
      final lightHighContrast = SplashThemeData.fromTheme(lightTheme, highContrast: true);
      final darkHighContrast = SplashThemeData.fromTheme(darkTheme, highContrast: true);

      // Assert - Each mode should have consistent internal color relationships
      expect(lightNormal.backgroundColor, isNot(equals(darkNormal.backgroundColor)));
      expect(lightHighContrast.backgroundColor, isNot(equals(darkHighContrast.backgroundColor)));
      
      // High contrast modes should use pure colors
      expect(lightHighContrast.backgroundColor, Colors.white);
      expect(darkHighContrast.backgroundColor, Colors.black);
    });

    test('should handle copyWith correctly with high contrast', () {
      // Arrange
      final theme = ThemeData.light();
      final originalTheme = SplashThemeData.fromTheme(theme, highContrast: true);

      // Act
      final modifiedTheme = originalTheme.copyWith(
        logoColor: Colors.red,
      );

      // Assert
      expect(modifiedTheme.logoColor, Colors.red);
      expect(modifiedTheme.backgroundColor, originalTheme.backgroundColor);
      expect(modifiedTheme.scannerColor, originalTheme.scannerColor);
      expect(modifiedTheme.textColor, originalTheme.textColor);
      expect(modifiedTheme.glowColor, originalTheme.glowColor);
    });

    test('should have proper equality comparison with high contrast', () {
      // Arrange
      final theme = ThemeData.light();
      final themeData1 = SplashThemeData.fromTheme(theme, highContrast: true);
      final themeData2 = SplashThemeData.fromTheme(theme, highContrast: true);
      final themeData3 = SplashThemeData.fromTheme(theme, highContrast: false);

      // Assert
      expect(themeData1, equals(themeData2));
      expect(themeData1, isNot(equals(themeData3)));
      expect(themeData1.hashCode, equals(themeData2.hashCode));
      expect(themeData1.hashCode, isNot(equals(themeData3.hashCode)));
    });

    test('should provide appropriate glow colors for high contrast', () {
      // Arrange
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      // Act
      final lightHighContrast = SplashThemeData.fromTheme(lightTheme, highContrast: true);
      final darkHighContrast = SplashThemeData.fromTheme(darkTheme, highContrast: true);

      // Assert - Glow colors should have appropriate alpha for visibility
      expect(lightHighContrast.glowColor.alpha, greaterThan(0));
      expect(lightHighContrast.glowColor.alpha, lessThan(255));
      expect(darkHighContrast.glowColor.alpha, greaterThan(0));
      expect(darkHighContrast.glowColor.alpha, lessThan(255));
      
      // Glow colors should be based on the text color for high contrast
      expect(lightHighContrast.glowColor.red, equals(Colors.black.red));
      expect(darkHighContrast.glowColor.red, equals(Colors.white.red));
    });
  });
}