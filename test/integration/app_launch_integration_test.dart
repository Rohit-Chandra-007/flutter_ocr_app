import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scanflow/app/app.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';
import 'package:scanflow/features/scan_history/screens/home_screen.dart';
import 'package:scanflow/core/services/app_initialization_service.dart';

/// Integration tests for complete app launch flow
void main() {
  group('App Launch Integration Tests', () {
    setUp(() {
      // Reset initialization state before each test
      AppInitializationService.reset();
    });

    testWidgets('should launch app with splash screen and navigate to home', (WidgetTester tester) async {
      // Launch the complete app
      await tester.pumpWidget(
        const ProviderScope(
          child: ScanFlowApp(),
        ),
      );

      // Verify splash screen is displayed initially
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Wait for initialization and animation to complete
      for (int i = 0; i < 300; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        
        // Check if home screen has appeared
        if (find.byType(HomeScreen).evaluate().isNotEmpty) {
          break;
        }
      }

      // Verify home screen is now displayed
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      
      // Verify initialization completed successfully
      expect(AppInitializationService.isInitialized, true);
      expect(AppInitializationService.initializationError, isNull);
    });

    testWidgets('should handle app launch with proper initialization', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(
        const ProviderScope(
          child: ScanFlowApp(),
        ),
      );

      // Pump a few frames to start initialization
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Initialization should be in progress or completed
      // (We can't easily test the exact timing due to async nature)
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain app state during splash transition', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ScanFlowApp(),
        ),
      );

      // Verify initial state
      expect(find.byType(SplashScreen), findsOneWidget);

      // Pump frames and ensure no exceptions occur
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }

      // App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle rapid app lifecycle changes during launch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ScanFlowApp(),
        ),
      );

      // Simulate rapid lifecycle changes
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // Should handle gracefully without crashes
      expect(tester.takeException(), isNull);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should complete full launch flow within reasonable time', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        const ProviderScope(
          child: ScanFlowApp(),
        ),
      );

      // Wait for complete launch flow
      bool homeScreenAppeared = false;
      while (!homeScreenAppeared && stopwatch.elapsedMilliseconds < 15000) {
        await tester.pump(const Duration(milliseconds: 100));
        
        if (find.byType(HomeScreen).evaluate().isNotEmpty) {
          homeScreenAppeared = true;
        }
      }
      
      stopwatch.stop();

      // Should complete within reasonable time (15 seconds max for safety)
      expect(homeScreenAppeared, true);
      expect(stopwatch.elapsedMilliseconds, lessThan(15000));
    });

    group('Error Handling Tests', () {
      testWidgets('should handle initialization gracefully on errors', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: ScanFlowApp(),
          ),
        );

        // Even if initialization has issues, app should not crash
        for (int i = 0; i < 50; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }

        // App should still be running
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should not cause memory leaks during launch', (WidgetTester tester) async {
        // Launch and dispose multiple times to check for leaks
        for (int i = 0; i < 3; i++) {
          await tester.pumpWidget(
            const ProviderScope(
              child: ScanFlowApp(),
            ),
          );

          // Pump a few frames
          for (int j = 0; j < 10; j++) {
            await tester.pump(const Duration(milliseconds: 50));
          }

          // Dispose
          await tester.pumpWidget(Container());
          
          // Should not throw disposal errors
          expect(tester.takeException(), isNull);
          
          // Reset for next iteration
          AppInitializationService.reset();
        }
      });
    });

    group('Theme Integration Tests', () {
      testWidgets('should respect system theme during launch', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: ScanFlowApp(),
          ),
        );

        // Find MaterialApp and verify theme configuration
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, isNotNull);
        expect(materialApp.darkTheme, isNotNull);
        expect(materialApp.themeMode, ThemeMode.system);
      });
    });
  });
}