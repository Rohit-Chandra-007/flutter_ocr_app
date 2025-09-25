import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scanflow/features/splash/widgets/splash_navigation_wrapper.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';
import 'package:scanflow/features/scan_history/screens/home_screen.dart';

/// Integration tests for splash screen to home screen navigation flow
void main() {
  group('Splash Navigation Integration Tests', () {
    late Widget testApp;

    setUp(() {
      // Use a simple theme to avoid Google Fonts issues in tests
      testApp = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const SplashNavigationWrapper(),
        ),
      );
    });

    testWidgets('should display splash screen initially', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('should transition to home screen after animation completes', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // Verify splash screen is initially displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      
      // Pump frames to advance animation
      for (int i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        
        // Check if home screen has appeared
        if (find.byType(HomeScreen).evaluate().isNotEmpty) {
          break;
        }
      }
      
      // Verify home screen is now displayed
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should have smooth transition without jarring flashes', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // Track opacity changes during transition
      final opacityValues = <double>[];
      
      // Pump frames and collect opacity values
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        
        // Try to find opacity widgets and record their values
        final opacityWidgets = tester.widgetList<Opacity>(find.byType(Opacity));
        for (final opacity in opacityWidgets) {
          opacityValues.add(opacity.opacity);
        }
      }
      
      // Ensure we have some opacity transitions recorded
      expect(opacityValues.isNotEmpty, true);
      
      // Verify no jarring jumps (opacity should change gradually)
      for (int i = 1; i < opacityValues.length; i++) {
        final diff = (opacityValues[i] - opacityValues[i - 1]).abs();
        expect(diff, lessThan(0.5), reason: 'Opacity change too abrupt: ${opacityValues[i - 1]} -> ${opacityValues[i]}');
      }
    });

    testWidgets('should handle rapid navigation requests gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // Verify initial state
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Pump multiple frames rapidly to simulate fast navigation
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      // Should still be stable (no crashes or exceptions)
      expect(tester.takeException(), isNull);
      
      // Wait for complete animation with manual pumping
      for (int i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(HomeScreen).evaluate().isNotEmpty) {
          break;
        }
      }
      
      // Should successfully reach home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should properly dispose resources during navigation', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // Wait for transition to complete with manual pumping
      for (int i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(HomeScreen).evaluate().isNotEmpty) {
          break;
        }
      }
      
      // Verify home screen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Dispose the widget tree
      await tester.pumpWidget(Container());
      
      // Should not throw any disposal errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle animation interruption gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      
      // Start animation
      await tester.pump(const Duration(milliseconds: 500));
      
      // Simulate app lifecycle change (like backgrounding)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      
      // Should handle gracefully without crashes
      expect(tester.takeException(), isNull);
      
      // Should eventually complete transition
      for (int i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(HomeScreen).evaluate().isNotEmpty) {
          break;
        }
      }
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    group('Navigation Timing Tests', () {
      testWidgets('should start home screen transition at correct timing', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        
        // Track when home screen first appears
        bool homeScreenAppeared = false;
        int frameCount = 0;
        
        while (!homeScreenAppeared && frameCount < 200) {
          await tester.pump(const Duration(milliseconds: 50));
          frameCount++;
          
          if (find.byType(HomeScreen).evaluate().isNotEmpty) {
            homeScreenAppeared = true;
          }
        }
        
        // Home screen should appear within reasonable time
        expect(homeScreenAppeared, true, reason: 'Home screen should appear during animation');
        expect(frameCount, greaterThan(10), reason: 'Home screen appeared too early');
        expect(frameCount, lessThan(200), reason: 'Home screen appeared too late');
      });
    });
  });
}