import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/controllers/splash_controller.dart';
import 'package:scanflow/features/splash/models/splash_animation_config.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';

void main() {
  group('Splash Animation Sequence Integration Tests', () {
    testWidgets('should complete full animation sequence with proper timing', (WidgetTester tester) async {
      bool animationCompleted = false;
      
      // Build the splash screen
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
            },
          ),
        ),
      );
      
      // Initial state - animation should not be completed yet
      expect(animationCompleted, false);
      
      // Pump to start animation
      await tester.pump();
      
      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Let animation run for a short time to ensure it starts
      await tester.pump(const Duration(milliseconds: 100));
      expect(animationCompleted, false);
      
      // Let the full animation sequence complete
      await tester.pump(SplashAnimationConfig.totalDuration);
      await tester.pumpAndSettle();
      
      // Animation should be completed
      expect(animationCompleted, true);
    });
    
    testWidgets('should maintain 1-second hold duration', (WidgetTester tester) async {
      bool animationCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
            },
          ),
        ),
      );
      
      await tester.pump();
      
      // Verify hold duration is exactly 1 second as configured
      expect(SplashAnimationConfig.holdDuration, const Duration(milliseconds: 1000));
      
      // Calculate when hold phase should start
      final preHoldDuration = SplashAnimationConfig.scannerDuration +
          SplashAnimationConfig.logoRevealDuration +
          SplashAnimationConfig.textFadeDuration;
      
      // Fast-forward to just before hold phase
      await tester.pump(preHoldDuration);
      expect(animationCompleted, false);
      
      // Pump half the hold duration - should still be holding
      await tester.pump(const Duration(milliseconds: 500));
      expect(animationCompleted, false);
      
      // Complete the rest of the animation
      await tester.pump(SplashAnimationConfig.holdDuration + SplashAnimationConfig.exitFadeDuration);
      await tester.pumpAndSettle();
      
      // Should be completed now
      expect(animationCompleted, true);
    });
    
    testWidgets('should handle animation completion callback correctly', (WidgetTester tester) async {
      bool callbackTriggered = false;
      int callbackCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              callbackTriggered = true;
              callbackCount++;
            },
          ),
        ),
      );
      
      await tester.pump();
      
      // Initially callback should not be triggered
      expect(callbackTriggered, false);
      expect(callbackCount, 0);
      
      // Let animation complete
      await tester.pump(SplashAnimationConfig.totalDuration);
      await tester.pumpAndSettle();
      
      // Callback should be triggered exactly once
      expect(callbackTriggered, true);
      expect(callbackCount, 1);
    });
    
    testWidgets('should ensure smooth transitions between phases', (WidgetTester tester) async {
      bool animationCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
            },
          ),
        ),
      );
      
      await tester.pump();
      
      // Test that animation progresses smoothly by checking at intervals
      const int steps = 10;
      final stepDuration = Duration(milliseconds: SplashAnimationConfig.totalDuration.inMilliseconds ~/ steps);
      
      for (int i = 0; i < steps; i++) {
        await tester.pump(stepDuration);
        
        // Animation should not complete until the very end
        if (i < steps - 1) {
          expect(animationCompleted, false, reason: 'Animation should not complete at step $i');
        }
      }
      
      // Final pump to ensure completion
      await tester.pumpAndSettle();
      expect(animationCompleted, true);
    });
    
    testWidgets('should handle animation state management throughout sequence', (WidgetTester tester) async {
      bool animationCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
            },
          ),
        ),
      );
      
      await tester.pump();
      
      // Verify splash screen is present and animation hasn't completed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(animationCompleted, false);
      
      // Test animation progression through different phases
      await tester.pump(SplashAnimationConfig.scannerDuration ~/ 2);
      expect(animationCompleted, false);
      
      await tester.pump(SplashAnimationConfig.logoRevealDuration ~/ 2);
      expect(animationCompleted, false);
      
      await tester.pump(SplashAnimationConfig.textFadeDuration ~/ 2);
      expect(animationCompleted, false);
      
      // Complete remaining animation
      await tester.pump(SplashAnimationConfig.totalDuration);
      await tester.pumpAndSettle();
      
      expect(animationCompleted, true);
    });
    
    testWidgets('should handle animation lifecycle correctly', (WidgetTester tester) async {
      bool animationCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
            },
          ),
        ),
      );
      
      await tester.pump();
      
      // Animation should start automatically
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(animationCompleted, false);
      
      // Let animation progress partway
      await tester.pump(const Duration(milliseconds: 500));
      expect(animationCompleted, false);
      
      // Complete animation
      await tester.pump(SplashAnimationConfig.totalDuration);
      await tester.pumpAndSettle();
      
      expect(animationCompleted, true);
    });
    
    testWidgets('should complete animation within expected timeframe', (WidgetTester tester) async {
      bool animationCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
            },
          ),
        ),
      );
      
      await tester.pump();
      
      // Animation should not complete immediately
      expect(animationCompleted, false);
      
      // Should complete within the configured total duration
      await tester.pump(SplashAnimationConfig.totalDuration);
      await tester.pumpAndSettle();
      
      expect(animationCompleted, true);
    });
    
    testWidgets('should coordinate animation phases in proper sequence', (WidgetTester tester) async {
      bool animationCompleted = false;
      final List<String> phaseLog = [];
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              animationCompleted = true;
              phaseLog.add('completed');
            },
          ),
        ),
      );
      
      await tester.pump();
      phaseLog.add('started');
      
      // Test each phase duration individually
      await tester.pump(SplashAnimationConfig.scannerDuration);
      phaseLog.add('scanner_done');
      
      await tester.pump(SplashAnimationConfig.logoRevealDuration);
      phaseLog.add('logo_done');
      
      await tester.pump(SplashAnimationConfig.textFadeDuration);
      phaseLog.add('text_done');
      
      await tester.pump(SplashAnimationConfig.holdDuration);
      phaseLog.add('hold_done');
      
      await tester.pump(SplashAnimationConfig.exitFadeDuration);
      await tester.pumpAndSettle();
      phaseLog.add('exit_done');
      
      // Verify proper sequence and completion
      // Note: completion callback may be triggered before exit_done due to animation timing
      expect(phaseLog, contains('started'));
      expect(phaseLog, contains('scanner_done'));
      expect(phaseLog, contains('logo_done'));
      expect(phaseLog, contains('text_done'));
      expect(phaseLog, contains('hold_done'));
      expect(phaseLog, contains('exit_done'));
      expect(phaseLog, contains('completed'));
      
      // Verify phases are in correct order (allowing for completion timing)
      expect(phaseLog.indexOf('started'), lessThan(phaseLog.indexOf('scanner_done')));
      expect(phaseLog.indexOf('scanner_done'), lessThan(phaseLog.indexOf('logo_done')));
      expect(phaseLog.indexOf('logo_done'), lessThan(phaseLog.indexOf('text_done')));
      expect(phaseLog.indexOf('text_done'), lessThan(phaseLog.indexOf('hold_done')));
      expect(animationCompleted, true);
    });

    group('Animation Timing Validation', () {
      testWidgets('should respect configured animation intervals', (WidgetTester tester) async {
        // Verify that animation intervals are properly calculated
        expect(SplashAnimationConfig.scannerEndInterval, greaterThan(0.0));
        expect(SplashAnimationConfig.scannerEndInterval, lessThan(SplashAnimationConfig.logoRevealEndInterval));
        expect(SplashAnimationConfig.logoRevealEndInterval, lessThan(SplashAnimationConfig.textFadeEndInterval));
        expect(SplashAnimationConfig.textFadeEndInterval, lessThan(SplashAnimationConfig.holdEndInterval));
        expect(SplashAnimationConfig.holdEndInterval, lessThan(1.0));
        
        // Verify hold duration is exactly 1 second as required
        expect(SplashAnimationConfig.holdDuration, const Duration(milliseconds: 1000));
      });
      
      testWidgets('should maintain consistent timing across animation phases', (WidgetTester tester) async {
        bool animationCompleted = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(
              onAnimationComplete: () {
                animationCompleted = true;
              },
            ),
          ),
        );
        
        await tester.pump();
        
        // Test that animation timing is consistent with configuration
        final totalDuration = SplashAnimationConfig.totalDuration;
        expect(totalDuration.inMilliseconds, greaterThan(0));
        
        // Animation should not complete before expected duration
        await tester.pump(Duration(milliseconds: totalDuration.inMilliseconds - 100));
        expect(animationCompleted, false);
        
        // Should complete after full duration
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });
    });
  });
}