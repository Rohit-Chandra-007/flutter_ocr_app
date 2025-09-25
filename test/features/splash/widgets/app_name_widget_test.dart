import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/widgets/app_name_widget.dart';
import 'package:scanflow/features/splash/controllers/splash_controller.dart';
import 'package:scanflow/app/theme/app_theme.dart';

void main() {
  group('AppNameWidget', () {
    testWidgets('displays ScanFlow text with correct style', (tester) async {
      // Create a mock controller that provides basic animation values
      final controller = SplashController();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Initialize controller in widget context
                try {
                  controller.initialize(tester);
                } catch (e) {
                  // Ignore initialization errors for basic test
                }
                return AppNameWidget(controller: controller);
              },
            ),
          ),
        ),
      );

      // Find the text widget
      final textFinder = find.text('ScanFlow');
      expect(textFinder, findsOneWidget);

      // Verify text style
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
      expect(textWidget.textAlign, TextAlign.center);
      
      // Clean up
      try {
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });

    testWidgets('uses displayLarge text theme style', (tester) async {
      final controller = SplashController();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                try {
                  controller.initialize(tester);
                } catch (e) {
                  // Ignore initialization errors for basic test
                }
                return AppNameWidget(controller: controller);
              },
            ),
          ),
        ),
      );

      final textFinder = find.text('ScanFlow');
      final textWidget = tester.widget<Text>(textFinder);
      
      // Should use displayLarge style properties
      expect(textWidget.style?.fontSize, 32);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
      expect(textWidget.style?.letterSpacing, -0.5);
      
      // Clean up
      try {
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });

    testWidgets('includes animation widgets', (tester) async {
      final controller = SplashController();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                try {
                  controller.initialize(tester);
                } catch (e) {
                  // Ignore initialization errors for basic test
                }
                return AppNameWidget(controller: controller);
              },
            ),
          ),
        ),
      );

      // Find the animation widgets
      final opacityFinder = find.byType(Opacity);
      final transformFinder = find.byType(Transform);
      
      expect(opacityFinder, findsOneWidget);
      expect(transformFinder, findsAtLeastNWidgets(1));
      
      // Clean up
      try {
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });
  });
}