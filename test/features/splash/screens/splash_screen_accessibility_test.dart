import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';
import 'package:scanflow/features/splash/services/accessibility_service.dart';

void main() {
  group('SplashScreen Accessibility', () {
    testWidgets('should provide semantic labels for screen readers', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert - Check that semantic widgets exist
      expect(find.byType(Semantics), findsWidgets);
      expect(find.text('ScanFlow'), findsOneWidget);
      
      // Check for semantic labels in the widget tree
      final semanticsWidgets = tester.widgetList<Semantics>(find.byType(Semantics));
      expect(semanticsWidgets.length, greaterThan(0));
      
      // Verify that semantic labels are present
      bool hasAppNameLabel = false;
      bool hasLogoLabel = false;
      
      for (final widget in semanticsWidgets) {
        final label = widget.properties.label;
        if (label != null) {
          if (label.contains('ScanFlow app name')) hasAppNameLabel = true;
          if (label.contains('ScanFlow logo')) hasLogoLabel = true;
        }
      }
      
      expect(hasAppNameLabel, isTrue);
      expect(hasLogoLabel, isTrue);
    });

    testWidgets('should support reduced motion preferences', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Test with reduced motion enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
          ),
          child: MaterialApp(
            home: SplashScreen(
              onAnimationComplete: () => callbackTriggered = true,
            ),
          ),
        ),
      );

      // Assert - Should render without errors and show reduced motion behavior
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ScanFlow'), findsOneWidget);
      
      // Check that semantic widgets exist with reduced motion description
      final semanticsWidgets = tester.widgetList<Semantics>(find.byType(Semantics));
      bool hasReducedMotionLabel = false;
      
      for (final widget in semanticsWidgets) {
        final label = widget.properties.label;
        if (label != null && label.contains('reduced for accessibility')) {
          hasReducedMotionLabel = true;
          break;
        }
      }
      
      expect(hasReducedMotionLabel, isTrue);
    });

    testWidgets('should support high contrast mode', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            highContrast: true,
          ),
          child: MaterialApp(
            home: SplashScreen(
              onAnimationComplete: () => callbackTriggered = true,
            ),
          ),
        ),
      );

      // Assert - Should render without errors in high contrast mode
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ScanFlow'), findsOneWidget);
    });

    testWidgets('should support bold text preferences', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            boldText: true,
          ),
          child: MaterialApp(
            home: SplashScreen(
              onAnimationComplete: () => callbackTriggered = true,
            ),
          ),
        ),
      );

      // Assert - Should render with bold text
      expect(find.byType(SplashScreen), findsOneWidget);
      
      final textWidget = tester.widget<Text>(find.text('ScanFlow'));
      expect(textWidget.style?.fontWeight, FontWeight.w900);
    });

    testWidgets('should provide live region updates for screen readers', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert - Should have semantics widget with live region
      expect(find.byType(Semantics), findsWidgets);
      
      // Check that the main semantics widget exists
      final semanticsWidgets = tester.widgetList<Semantics>(find.byType(Semantics));
      expect(semanticsWidgets.length, greaterThan(0));
      
      // Verify that at least one semantics widget has liveRegion set to true
      final hasLiveRegion = semanticsWidgets.any((widget) => widget.properties.liveRegion == true);
      expect(hasLiveRegion, isTrue);
    });

    testWidgets('should handle multiple accessibility features simultaneously', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act - Enable multiple accessibility features
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            highContrast: true,
            boldText: true,
          ),
          child: MaterialApp(
            home: SplashScreen(
              onAnimationComplete: () => callbackTriggered = true,
            ),
          ),
        ),
      );

      // Assert - Should handle all features gracefully
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ScanFlow'), findsOneWidget);
      
      // Check for reduced motion description in semantics
      final semanticsWidgets = tester.widgetList<Semantics>(find.byType(Semantics));
      bool hasReducedMotionLabel = false;
      
      for (final widget in semanticsWidgets) {
        final label = widget.properties.label;
        if (label != null && label.contains('reduced for accessibility')) {
          hasReducedMotionLabel = true;
          break;
        }
      }
      
      expect(hasReducedMotionLabel, isTrue);
      
      final textWidget = tester.widget<Text>(find.text('ScanFlow'));
      expect(textWidget.style?.fontWeight, FontWeight.w900);
    });

    testWidgets('should provide appropriate semantic labels for different states', (tester) async {
      // Test semantic label generation
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
    });

    testWidgets('should detect accessibility features correctly', (tester) async {
      // Test reduced motion detection
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

      // Test high contrast detection
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

      // Test bold text detection
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

      // Test screen reader detection (using disableAnimations as proxy)
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
    });

    testWidgets('should provide appropriate accessibility timeout', (tester) async {
      // Test normal timeout
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

      // Test accessibility timeout
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
    });

    testWidgets('should handle theme changes with accessibility features', (tester) async {
      // Arrange
      bool callbackTriggered = false;
      ValueNotifier<bool> highContrastNotifier = ValueNotifier(false);

      // Act - Start with normal theme
      await tester.pumpWidget(
        ValueListenableBuilder<bool>(
          valueListenable: highContrastNotifier,
          builder: (context, highContrast, child) {
            return MediaQuery(
              data: MediaQueryData(
                highContrast: highContrast,
              ),
              child: MaterialApp(
                theme: highContrast ? ThemeData.light() : ThemeData.dark(),
                home: SplashScreen(
                  onAnimationComplete: () => callbackTriggered = true,
                ),
              ),
            );
          },
        ),
      );

      // Verify initial state
      expect(find.byType(SplashScreen), findsOneWidget);

      // Act - Switch to high contrast
      highContrastNotifier.value = true;
      await tester.pumpAndSettle();

      // Assert - Should adapt to high contrast
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ScanFlow'), findsOneWidget);
    });
  });
}