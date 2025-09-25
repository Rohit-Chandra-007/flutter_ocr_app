import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/models/splash_theme_data.dart';

void main() {
  group('SplashThemeData', () {
    group('fromTheme', () {
      test('should extract correct colors from light theme', () {
        // Arrange
        final lightTheme = ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4A90E2),
            secondary: Color(0xFF50E3C2),
            onSurface: Color(0xFF1A1A1A),
          ),
        );

        // Act
        final themeData = SplashThemeData.fromTheme(lightTheme);

        // Assert
        expect(themeData.backgroundColor, const Color(0xFFF8F9FA));
        expect(themeData.logoColor, const Color(0xFF4A90E2));
        expect(themeData.scannerColor, const Color(0xFF50E3C2));
        expect(themeData.textColor, const Color(0xFF1A1A1A));
        expect(themeData.glowColor.alpha, (0.2 * 255).round());
      });

      test('should extract correct colors from dark theme', () {
        // Arrange
        final darkTheme = ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A90E2),
            secondary: Color(0xFF50E3C2),
            onSurface: Color(0xFFE0E0E0),
          ),
        );

        // Act
        final themeData = SplashThemeData.fromTheme(darkTheme);

        // Assert
        expect(themeData.backgroundColor, const Color(0xFF121212));
        expect(themeData.logoColor, const Color(0xFF4A90E2));
        expect(themeData.scannerColor, const Color(0xFF50E3C2));
        expect(themeData.textColor, const Color(0xFFE0E0E0));
        expect(themeData.glowColor.alpha, (0.3 * 255).round());
      });

      test('should use different glow opacity for dark vs light themes', () {
        // Arrange
        final lightTheme = ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            secondary: Color(0xFF50E3C2),
          ),
        );
        final darkTheme = ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            secondary: Color(0xFF50E3C2),
          ),
        );

        // Act
        final lightThemeData = SplashThemeData.fromTheme(lightTheme);
        final darkThemeData = SplashThemeData.fromTheme(darkTheme);

        // Assert
        expect(lightThemeData.glowColor.alpha, (0.2 * 255).round());
        expect(darkThemeData.glowColor.alpha, (0.3 * 255).round());
      });
    });

    group('copyWith', () {
      test('should create copy with modified properties', () {
        // Arrange
        const original = SplashThemeData(
          backgroundColor: Colors.white,
          logoColor: Colors.blue,
          scannerColor: Colors.green,
          textColor: Colors.black,
          glowColor: Colors.grey,
        );

        // Act
        final modified = original.copyWith(
          backgroundColor: Colors.red,
          logoColor: Colors.yellow,
        );

        // Assert
        expect(modified.backgroundColor, Colors.red);
        expect(modified.logoColor, Colors.yellow);
        expect(modified.scannerColor, Colors.green); // unchanged
        expect(modified.textColor, Colors.black); // unchanged
        expect(modified.glowColor, Colors.grey); // unchanged
      });

      test('should return identical copy when no properties changed', () {
        // Arrange
        const original = SplashThemeData(
          backgroundColor: Colors.white,
          logoColor: Colors.blue,
          scannerColor: Colors.green,
          textColor: Colors.black,
          glowColor: Colors.grey,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.backgroundColor, original.backgroundColor);
        expect(copy.logoColor, original.logoColor);
        expect(copy.scannerColor, original.scannerColor);
        expect(copy.textColor, original.textColor);
        expect(copy.glowColor, original.glowColor);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const themeData1 = SplashThemeData(
          backgroundColor: Colors.white,
          logoColor: Colors.blue,
          scannerColor: Colors.green,
          textColor: Colors.black,
          glowColor: Colors.grey,
        );
        const themeData2 = SplashThemeData(
          backgroundColor: Colors.white,
          logoColor: Colors.blue,
          scannerColor: Colors.green,
          textColor: Colors.black,
          glowColor: Colors.grey,
        );

        // Act & Assert
        expect(themeData1, equals(themeData2));
        expect(themeData1.hashCode, equals(themeData2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const themeData1 = SplashThemeData(
          backgroundColor: Colors.white,
          logoColor: Colors.blue,
          scannerColor: Colors.green,
          textColor: Colors.black,
          glowColor: Colors.grey,
        );
        const themeData2 = SplashThemeData(
          backgroundColor: Colors.red, // different
          logoColor: Colors.blue,
          scannerColor: Colors.green,
          textColor: Colors.black,
          glowColor: Colors.grey,
        );

        // Act & Assert
        expect(themeData1, isNot(equals(themeData2)));
      });
    });
  });
}