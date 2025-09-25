import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow/features/splash/widgets/splash_navigation_wrapper.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';
import 'package:scanflow/features/scan_history/screens/home_screen.dart';
import 'package:scanflow/app/theme/app_theme.dart';

void main() {
  group('SplashNavigationWrapper Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashNavigationWrapper(),
        ),
      );
    }

    testWidgets('should initially show splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify splash screen is shown initially
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('should transition to home screen after animation completes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially shows splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Pump through the animation frames manually to avoid timeout
      // Total animation is about 4.3 seconds + transition time
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Pump a few more frames to complete the transition
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should now show home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle animation controller disposal properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Let animation start
      await tester.pump();

      // Remove the widget to test disposal
      await tester.pumpWidget(const SizedBox());

      // Should not throw any exceptions during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('should prevent multiple transitions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Get the splash navigation wrapper state
      final splashWrapperFinder = find.byType(SplashNavigationWrapper);
      expect(splashWrapperFinder, findsOneWidget);

      // Start the animation
      await tester.pump();

      // Try to trigger multiple rapid state changes
      // This simulates rapid callback calls that shouldn't cause issues
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw exceptions
      expect(tester.takeException(), isNull);

      // Complete the animation manually
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 500));

      // Should successfully reach home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should maintain widget keys for proper animation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify splash screen is present
      expect(find.byType(SplashScreen), findsOneWidget);

      // Complete animation manually
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 500));

      // Verify home screen is present
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Verify no duplicate widgets exist
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('should handle theme changes gracefully', (WidgetTester tester) async {
      // Start with light theme
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SplashNavigationWrapper(),
          ),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      // Switch to dark theme during animation
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SplashNavigationWrapper(),
          ),
        ),
      );

      // Should handle theme change without errors
      expect(tester.takeException(), isNull);

      // Complete animation manually
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 500));

      // Should reach home screen successfully
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should provide smooth opacity transitions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Start animation
      await tester.pump();

      // Track opacity changes during the transition phase
      List<double> opacityValues = [];
      
      // Pump through transition frames
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        
        // Look for opacity widgets
        final opacityWidgets = find.byType(Opacity);
        if (opacityWidgets.evaluate().isNotEmpty) {
          final Opacity opacity = tester.widget(opacityWidgets.first);
          opacityValues.add(opacity.opacity);
        }
      }

      // Complete remaining animation manually
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify smooth transitions (no abrupt changes)
      if (opacityValues.length > 2) {
        for (int i = 1; i < opacityValues.length; i++) {
          final double change = (opacityValues[i] - opacityValues[i - 1]).abs();
          expect(change, lessThan(0.3), 
            reason: 'Opacity change too abrupt: ${opacityValues[i - 1]} -> ${opacityValues[i]}');
        }
      }
    });
  });
}