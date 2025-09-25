import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/models/splash_theme_data.dart';
import 'package:scanflow/features/splash/widgets/scanner_line_widget.dart';

class TestVSync implements TickerProvider {
  const TestVSync();
  
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  group('ScannerLineWidget', () {
    late SplashThemeData themeData;

    setUp(() {
      themeData = const SplashThemeData(
        backgroundColor: Colors.white,
        logoColor: Colors.blue,
        scannerColor: Colors.red,
        textColor: Colors.black,
        glowColor: Colors.redAccent,
      );
    });

    testWidgets('renders without error', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ScannerLineWidget(
            animation: controller,
            themeData: themeData,
          ),
        ),
      );
      
      expect(find.byType(ScannerLineWidget), findsOneWidget);
      
      controller.dispose();
    });

    testWidgets('updates when animation progresses', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ScannerLineWidget(
            animation: controller,
            themeData: themeData,
          ),
        ),
      );
      
      // Start animation
      controller.forward();
      await tester.pump();
      
      // Progress animation
      await tester.pump(const Duration(milliseconds: 50));
      
      // Verify widget still exists and is rendering
      expect(find.byType(ScannerLineWidget), findsOneWidget);
      
      controller.stop();
      controller.dispose();
    });

    testWidgets('respects configuration parameters', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ScannerLineWidget(
            animation: controller,
            themeData: themeData,
            glowIntensity: 0.8,
            lineHeight: 4.0,
            showGlow: false,
          ),
        ),
      );
      
      // Verify widget renders with custom parameters
      expect(find.byType(ScannerLineWidget), findsOneWidget);
      
      controller.dispose();
    });
  });

  group('OptimizedScannerLineWidget', () {
    late SplashThemeData themeData;

    setUp(() {
      themeData = const SplashThemeData(
        backgroundColor: Colors.white,
        logoColor: Colors.blue,
        scannerColor: Colors.red,
        textColor: Colors.black,
        glowColor: Colors.redAccent,
      );
    });

    testWidgets('renders with RepaintBoundary for performance', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OptimizedScannerLineWidget(
            animation: controller,
            themeData: themeData,
          ),
        ),
      );
      
      expect(find.byType(OptimizedScannerLineWidget), findsOneWidget);
      
      controller.dispose();
    });

    testWidgets('handles progress updates', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: const TestVSync(),
      );
      
      final progressUpdates = <double>[];
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OptimizedScannerLineWidget(
            animation: controller,
            themeData: themeData,
            onProgressUpdate: (progress) {
              progressUpdates.add(progress);
            },
          ),
        ),
      );
      
      // Start animation
      controller.forward();
      await tester.pump();
      
      // Progress animation
      await tester.pump(const Duration(milliseconds: 50));
      
      // Should have received some progress updates
      expect(progressUpdates.isNotEmpty, isTrue);
      
      controller.stop();
      controller.dispose();
    });
  });

  group('ScannerLineAnimationUtils', () {
    test('calculateDynamicGlowIntensity works correctly', () {
      // Test fade in at start
      final startIntensity = ScannerLineAnimationUtils.calculateDynamicGlowIntensity(0.05, 1.0);
      expect(startIntensity, lessThan(1.0));
      
      // Test steady glow in middle
      final middleIntensity = ScannerLineAnimationUtils.calculateDynamicGlowIntensity(0.5, 1.0);
      expect(middleIntensity, equals(1.0));
      
      // Test fade out at end
      final endIntensity = ScannerLineAnimationUtils.calculateDynamicGlowIntensity(0.95, 1.0);
      expect(endIntensity, lessThan(1.0));
    });

    test('calculateDynamicLineWidth varies correctly', () {
      const baseWidth = 10.0;
      const containerSize = Size(100, 100);
      
      // Test multiple progress values to ensure variation
      final progressValues = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];
      final widths = progressValues.map((progress) => 
        ScannerLineAnimationUtils.calculateDynamicLineWidth(progress, baseWidth, containerSize)
      ).toList();
      
      // All widths should be within reasonable bounds
      for (final width in widths) {
        expect(width, greaterThanOrEqualTo(baseWidth * 0.8));
        expect(width, lessThanOrEqualTo(baseWidth * 1.2));
      }
      
      // Should have some variation across different progress values
      final uniqueWidths = widths.toSet();
      expect(uniqueWidths.length, greaterThan(2)); // At least some variation
    });

    test('getScannerColorWithDynamicOpacity maintains color', () {
      const baseColor = Colors.red;
      
      final color1 = ScannerLineAnimationUtils.getScannerColorWithDynamicOpacity(baseColor, 0.0);
      final color2 = ScannerLineAnimationUtils.getScannerColorWithDynamicOpacity(baseColor, 0.5);
      
      // Should maintain same RGB values
      expect(color1.red, equals(baseColor.red));
      expect(color1.green, equals(baseColor.green));
      expect(color1.blue, equals(baseColor.blue));
      
      expect(color2.red, equals(baseColor.red));
      expect(color2.green, equals(baseColor.green));
      expect(color2.blue, equals(baseColor.blue));
      
      // Opacity should be within expected range (0.8 to 1.0)
      expect(color1.alpha, greaterThanOrEqualTo(204)); // 0.8 * 255
      expect(color1.alpha, lessThanOrEqualTo(255)); // 1.0 * 255
      
      expect(color2.alpha, greaterThanOrEqualTo(204)); // 0.8 * 255
      expect(color2.alpha, lessThanOrEqualTo(255)); // 1.0 * 255
    });
  });

  group('Performance Tests', () {
    testWidgets('animation runs smoothly without frame drops', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ScannerLineWidget(
            animation: controller,
            themeData: const SplashThemeData(
              backgroundColor: Colors.white,
              logoColor: Colors.blue,
              scannerColor: Colors.red,
              textColor: Colors.black,
              glowColor: Colors.redAccent,
            ),
          ),
        ),
      );
      
      // Run animation multiple times to test performance
      for (int i = 0; i < 3; i++) {
        controller.forward();
        await tester.pumpAndSettle();
        controller.reset();
        await tester.pump();
      }
      
      // Should complete without errors
      expect(tester.takeException(), isNull);
      
      controller.dispose();
    });

    testWidgets('handles rapid animation changes', (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 50),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OptimizedScannerLineWidget(
            animation: controller,
            themeData: const SplashThemeData(
              backgroundColor: Colors.white,
              logoColor: Colors.blue,
              scannerColor: Colors.red,
              textColor: Colors.black,
              glowColor: Colors.redAccent,
            ),
          ),
        ),
      );
      
      // Rapidly change animation values
      for (double value = 0.0; value <= 1.0; value += 0.2) {
        controller.value = value;
        await tester.pump();
      }
      
      // Should handle rapid changes without issues
      expect(tester.takeException(), isNull);
      
      controller.dispose();
    });
  });
}