import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/services/accessibility_service.dart';

void main() {
  group('AccessibilityService', () {
    testWidgets('should detect reduced motion correctly', (tester) async {
      // Test with reduced motion enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isReducedMotionEnabled(context), isTrue);
              return Container();
            },
          ),
        ),
      );

      // Test with reduced motion disabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isReducedMotionEnabled(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect high contrast correctly', (tester) async {
      // Test with high contrast enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isHighContrastEnabled(context), isTrue);
              return Container();
            },
          ),
        ),
      );

      // Test with high contrast disabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: false),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isHighContrastEnabled(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect bold text correctly', (tester) async {
      // Test with bold text enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(boldText: true),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isBoldTextEnabled(context), isTrue);
              return Container();
            },
          ),
        ),
      );

      // Test with bold text disabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(boldText: false),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isBoldTextEnabled(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect screen reader correctly', (tester) async {
      // Test with screen reader active (using disableAnimations as proxy)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
          ),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isScreenReaderActive(context), isTrue);
              return Container();
            },
          ),
        ),
      );

      // Test with screen reader inactive
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: false,
          ),
          child: Builder(
            builder: (context) {
              expect(AccessibilityService.isScreenReaderActive(context), isFalse);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should provide correct accessibility timeout', (tester) async {
      // Test normal timeout (no accessibility features)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Builder(
            builder: (context) {
              final timeout = AccessibilityService.getAccessibilityTimeout(context);
              expect(timeout, const Duration(milliseconds: 2000));
              return Container();
            },
          ),
        ),
      );

      // Test accessibility timeout (with reduced motion)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
          ),
          child: Builder(
            builder: (context) {
              final timeout = AccessibilityService.getAccessibilityTimeout(context);
              expect(timeout, const Duration(milliseconds: 500));
              return Container();
            },
          ),
        ),
      );

      // Test accessibility timeout (with bold text)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            boldText: true,
          ),
          child: Builder(
            builder: (context) {
              final timeout = AccessibilityService.getAccessibilityTimeout(context);
              expect(timeout, const Duration(milliseconds: 500));
              return Container();
            },
          ),
        ),
      );

      // Test accessibility timeout (with high contrast)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            highContrast: true,
          ),
          child: Builder(
            builder: (context) {
              final timeout = AccessibilityService.getAccessibilityTimeout(context);
              expect(timeout, const Duration(milliseconds: 500));
              return Container();
            },
          ),
        ),
      );
    });

    test('should provide correct semantic labels for splash states', () {
      expect(
        AccessibilityService.getSplashStateSemanticLabel('scanning'),
        'ScanFlow app is loading, scanning animation in progress',
      );

      expect(
        AccessibilityService.getSplashStateSemanticLabel('revealingLogo'),
        'ScanFlow logo appearing',
      );

      expect(
        AccessibilityService.getSplashStateSemanticLabel('fadingInText'),
        'ScanFlow app name appearing',
      );

      expect(
        AccessibilityService.getSplashStateSemanticLabel('holding'),
        'ScanFlow app loaded successfully',
      );

      expect(
        AccessibilityService.getSplashStateSemanticLabel('exiting'),
        'Transitioning to main app',
      );

      expect(
        AccessibilityService.getSplashStateSemanticLabel('unknown'),
        'ScanFlow app is starting',
      );

      expect(
        AccessibilityService.getSplashStateSemanticLabel(''),
        'ScanFlow app is starting',
      );
    });

    test('should provide reduced motion description', () {
      expect(
        AccessibilityService.getReducedMotionDescription(),
        'ScanFlow app loading screen. Animations are reduced for accessibility.',
      );
    });
  });
}