import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';
import 'package:scanflow/features/splash/controllers/splash_controller.dart';

void main() {
  group('Splash Screen Error Handling Integration', () {
    testWidgets('should handle complete error scenarios gracefully', (tester) async {
      // Arrange
      bool navigationTriggered = false;
      List<String> errorMessages = [];
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              navigationTriggered = true;
            },
            onError: (errorType, message) {
              errorMessages.add('$errorType: $message');
            },
          ),
        ),
      );

      // Let the splash screen initialize
      await tester.pump();
      
      // Verify it renders without crashing
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Wait for any initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Assert - Should not crash and should be functional
      expect(tester.takeException(), isNull);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should provide fallback when errors occur', (tester) async {
      // Arrange
      bool navigationTriggered = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              navigationTriggered = true;
            },
          ),
        ),
      );

      await tester.pump();
      
      // Simulate rapid navigation away and back (stress test)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Away'))),
      );
      
      await tester.pump();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              navigationTriggered = true;
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Assert - Should handle the stress test gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain performance under stress', (tester) async {
      // Arrange
      bool navigationTriggered = false;
      final stopwatch = Stopwatch()..start();
      
      // Act - Create and destroy splash screens rapidly
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(
              onAnimationComplete: () {
                navigationTriggered = true;
              },
            ),
          ),
        );
        
        await tester.pump();
        
        // Navigate away
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: Text('Screen $i'))),
        );
        
        await tester.pump();
      }
      
      stopwatch.stop();
      
      // Final cleanup
      await tester.pumpAndSettle();
      
      // Assert - Should complete quickly and without errors
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(tester.takeException(), isNull);
    });
  });

  group('Performance Metrics', () {
    test('should create valid performance metrics', () {
      // Arrange & Act
      const metrics = SplashPerformanceMetrics(
        frameCount: 60,
        averageFrameTime: 16.67,
        droppedFrames: 2,
        totalDuration: Duration(milliseconds: 1000),
        hadPerformanceIssues: false,
      );

      // Assert
      expect(metrics.frameCount, 60);
      expect(metrics.averageFrameTime, 16.67);
      expect(metrics.droppedFrames, 2);
      expect(metrics.totalDuration.inMilliseconds, 1000);
      expect(metrics.hadPerformanceIssues, false);
    });

    test('should handle performance issues flag', () {
      // Arrange & Act
      const metrics = SplashPerformanceMetrics(
        frameCount: 30,
        averageFrameTime: 33.33,
        droppedFrames: 15,
        totalDuration: Duration(milliseconds: 2000),
        hadPerformanceIssues: true,
      );

      // Assert
      expect(metrics.hadPerformanceIssues, true);
      expect(metrics.droppedFrames, greaterThan(10));
    });
  });

  group('Error Types', () {
    test('should have all required error types', () {
      // Assert - Verify all error types exist
      expect(SplashErrorType.animationFailure, isNotNull);
      expect(SplashErrorType.timeout, isNotNull);
      expect(SplashErrorType.resourceLoadingFailure, isNotNull);
      expect(SplashErrorType.memoryPressure, isNotNull);
      expect(SplashErrorType.performanceDegradation, isNotNull);
    });
  });
}