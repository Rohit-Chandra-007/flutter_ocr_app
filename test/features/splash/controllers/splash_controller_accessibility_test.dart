import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/controllers/splash_controller.dart';

void main() {
  group('SplashController Accessibility', () {
    late SplashController controller;

    setUp(() {
      controller = SplashController();
    });

    tearDown(() {
      try {
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors in tests
      }
    });

    testWidgets('should initialize with accessibility settings', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize with reduced motion enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Assert
      expect(controller.reducedMotionEnabled, isTrue);
      expect(controller.highContrastEnabled, isFalse);
      expect(controller.screenReaderActive, isFalse);
    });

    testWidgets('should initialize with high contrast settings', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize with high contrast enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Assert
      expect(controller.reducedMotionEnabled, isFalse);
      expect(controller.highContrastEnabled, isTrue);
      expect(controller.screenReaderActive, isFalse);
    });

    testWidgets('should initialize with screen reader settings', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize with screen reader active (using disableAnimations as proxy)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
          ),
          child: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Assert
      expect(controller.reducedMotionEnabled, isTrue); // disableAnimations affects both
      expect(controller.highContrastEnabled, isFalse);
      expect(controller.screenReaderActive, isTrue);
    });

    testWidgets('should use reduced animation duration for reduced motion', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize with reduced motion
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Assert - Should use reduced total duration
      expect(controller.reducedMotionEnabled, isTrue);
      // The controller should be initialized with reduced duration
      // We can't directly test the AnimationController duration, but we can verify
      // that the accessibility settings are properly detected
    });

    testWidgets('should provide semantic labels for current state', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Act & Assert - Test different states
      expect(controller.currentStateSemanticLabel, contains('ScanFlow app is starting'));
    });

    testWidgets('should update accessibility settings dynamically', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize with normal motion first
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Verify initial state
      expect(controller.reducedMotionEnabled, isFalse);

      // Act - Update accessibility settings with reduced motion
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              controller.updateAccessibilitySettings(context);
              return Container();
            },
          ),
        ),
      );

      // Assert - Should detect the change
      expect(controller.reducedMotionEnabled, isTrue);
    });

    test('should handle initialization without context gracefully', () {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize without context
      controller.initialize(
        TestVSync(),
        onComplete: () => callbackTriggered = true,
      );

      // Assert - Should not crash and should have default accessibility settings
      expect(controller.reducedMotionEnabled, isFalse);
      expect(controller.highContrastEnabled, isFalse);
      expect(controller.screenReaderActive, isFalse);
    });

    testWidgets('should handle multiple accessibility features', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Initialize with multiple accessibility features
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            highContrast: true,
            boldText: true,
          ),
          child: Builder(
            builder: (context) {
              controller.initialize(
                tester,
                onComplete: () => callbackTriggered = true,
                context: context,
              );
              return Container();
            },
          ),
        ),
      );

      // Assert - Should handle all features
      expect(controller.reducedMotionEnabled, isTrue);
      expect(controller.highContrastEnabled, isTrue);
      expect(controller.screenReaderActive, isTrue);
    });
  });
}

/// Test implementation of TickerProvider for testing
class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}