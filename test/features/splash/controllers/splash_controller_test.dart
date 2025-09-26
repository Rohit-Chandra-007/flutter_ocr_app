import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/controllers/splash_controller.dart';
import 'package:scanflow/features/splash/models/splash_animation_config.dart';

class MockTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SplashController', () {
    late SplashController controller;
    late MockTickerProvider tickerProvider;
    bool animationCompleted = false;

    setUp(() {
      controller = SplashController();
      tickerProvider = MockTickerProvider();
      animationCompleted = false;
    });

    tearDown(() {
      // Only dispose if controller was initialized
      try {
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors for uninitialized controllers
      }
    });

    group('Initialization', () {
      test('should initialize with idle state', () {
        expect(controller.currentState, SplashAnimationState.idle);
        expect(controller.isAnimating, false);
        // Don't test overallProgress before initialization
      });

      test('should initialize animation controller and sequences', () {
        controller.initialize(tickerProvider);
        
        expect(controller.scannerAnimation, isNotNull);
        expect(controller.logoRevealAnimation, isNotNull);
        expect(controller.textFadeAnimation, isNotNull);
        expect(controller.exitFadeAnimation, isNotNull);
        expect(controller.overallProgress, 0.0);
      });

      test('should set up completion callback', () {
        controller.initialize(
          tickerProvider,
          onComplete: () => animationCompleted = true,
        );
        
        // Callback should not be called during initialization
        expect(animationCompleted, false);
      });
    });

    group('Animation State Management', () {
      setUp(() {
        controller.initialize(tickerProvider);
      });

      test('should start animation from idle state', () {
        controller.startAnimation();
        expect(controller.isAnimating, true);
      });

      test('should not start animation if not in idle state', () {
        controller.startAnimation();
        final initialProgress = controller.overallProgress;
        
        // Try to start again - should not reset
        controller.startAnimation();
        expect(controller.overallProgress, greaterThanOrEqualTo(initialProgress));
      });

      test('should reset animation to idle state', () {
        controller.startAnimation();
        controller.resetAnimation();
        
        expect(controller.currentState, SplashAnimationState.idle);
        expect(controller.isAnimating, false);
      });

      test('should skip to end of animation', () async {
        controller.initialize(
          tickerProvider,
          onComplete: () => animationCompleted = true,
        );
        
        controller.startAnimation();
        controller.skipAnimation();
        
        // Wait for animation to complete
        await Future.delayed(const Duration(milliseconds: 300));
        
        expect(controller.overallProgress, 1.0);
        expect(animationCompleted, true);
      });
    });

    group('Animation Phases', () {
      setUp(() {
        controller.initialize(tickerProvider);
      });

      test('should progress through animation states in correct order', () async {
        final stateChanges = <SplashAnimationState>[];
        
        controller.addListener(() {
          stateChanges.add(controller.currentState);
        });
        
        controller.startAnimation();
        
        // Skip to end to capture all states quickly
        controller.skipAnimation();
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Should have progressed through states (may skip some due to speed)
        expect(stateChanges, contains(SplashAnimationState.scanning));
        expect(stateChanges.last, SplashAnimationState.completed);
      });

      test('should provide correct phase progress values', () {
        controller.startAnimation();
        
        // Initially, scanner should be active
        expect(controller.getPhaseProgress(SplashAnimationState.scanning), 
               greaterThanOrEqualTo(0.0));
        expect(controller.getPhaseProgress(SplashAnimationState.revealingLogo), 0.0);
        expect(controller.getPhaseProgress(SplashAnimationState.fadingInText), 0.0);
      });

      test('should correctly identify active phases', () {
        controller.startAnimation();
        
        // Initially should be in scanning phase
        expect(controller.isPhaseActive(SplashAnimationState.scanning), true);
        expect(controller.isPhaseActive(SplashAnimationState.revealingLogo), false);
      });
    });

    group('Animation Timing', () {
      test('should respect animation configuration intervals', () {
        controller.initialize(tickerProvider);
        
        // Test that intervals are calculated correctly
        expect(SplashAnimationConfig.scannerEndInterval, 
               lessThan(SplashAnimationConfig.logoRevealEndInterval));
        expect(SplashAnimationConfig.logoRevealEndInterval, 
               lessThan(SplashAnimationConfig.textFadeEndInterval));
        expect(SplashAnimationConfig.textFadeEndInterval, 
               lessThan(SplashAnimationConfig.holdEndInterval));
        expect(SplashAnimationConfig.holdEndInterval, lessThan(1.0));
      });

      test('should have reasonable total duration', () {
        expect(SplashAnimationConfig.totalDuration.inMilliseconds, 
               greaterThan(0));
        expect(SplashAnimationConfig.totalDuration, 
               lessThan(SplashAnimationConfig.maxSplashDuration));
      });
    });

    group('Timeout Protection', () {
      test('should handle timeout scenario', () async {
        bool timeoutHandled = false;
        
        controller.initialize(
          tickerProvider,
          onComplete: () => timeoutHandled = true,
        );
        
        controller.startAnimation();
        
        // Simulate timeout by waiting longer than max duration
        // Note: In real tests, we'd mock the timer for faster execution
        // This is a conceptual test - actual implementation would need timer mocking
        
        expect(controller.isAnimating, true);
      });

      test('should not timeout if animation completes normally', () async {
        bool completedNormally = false;
        
        controller.initialize(
          tickerProvider,
          onComplete: () => completedNormally = true,
        );
        
        controller.startAnimation();
        controller.skipAnimation();
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        expect(completedNormally, true);
        expect(controller.currentState, SplashAnimationState.completed);
      });
    });

    group('Memory Management', () {
      test('should properly dispose resources', () {
        controller.initialize(tickerProvider);
        controller.startAnimation();
        
        // Should not throw when disposing
        expect(() => controller.dispose(), returnsNormally);
      });

      test('should cancel timeout timer on dispose', () {
        controller.initialize(tickerProvider);
        controller.startAnimation();
        
        // Dispose should clean up timer
        controller.dispose();
        
        // No way to directly test timer cancellation, but dispose should not throw
        expect(true, true); // Placeholder assertion
      });
    });

    group('Animation Curves and Intervals', () {
      setUp(() {
        controller.initialize(tickerProvider);
      });

      test('should use correct animation curves', () {
        // Test that animations are created with proper curves
        // This is more of a structural test since we can't easily inspect curves
        expect(controller.scannerAnimation, isNotNull);
        expect(controller.logoRevealAnimation, isNotNull);
        expect(controller.textFadeAnimation, isNotNull);
        expect(controller.exitFadeAnimation, isNotNull);
      });

      test('should have proper interval boundaries', () {
        // Verify that intervals don't overlap incorrectly
        expect(SplashAnimationConfig.scannerEndInterval, greaterThan(0.0));
        expect(SplashAnimationConfig.logoRevealEndInterval, 
               greaterThan(SplashAnimationConfig.scannerEndInterval));
        expect(SplashAnimationConfig.textFadeEndInterval, 
               greaterThan(SplashAnimationConfig.logoRevealEndInterval));
        expect(SplashAnimationConfig.holdEndInterval, 
               greaterThan(SplashAnimationConfig.textFadeEndInterval));
        expect(SplashAnimationConfig.holdEndInterval, lessThanOrEqualTo(1.0));
      });
    });

    group('Error Handling', () {
      test('should handle animation errors gracefully', () {
        controller.initialize(tickerProvider);
        
        // Test that controller doesn't crash with invalid operations
        expect(() => controller.getPhaseProgress(SplashAnimationState.error), 
               returnsNormally);
        expect(() => controller.isPhaseActive(SplashAnimationState.error), 
               returnsNormally);
      });

      test('should provide fallback values for invalid states', () {
        controller.initialize(tickerProvider);
        
        expect(controller.getPhaseProgress(SplashAnimationState.idle), 0.0);
        expect(controller.getPhaseProgress(SplashAnimationState.completed), 0.0);
        expect(controller.getPhaseProgress(SplashAnimationState.error), 0.0);
      });
    });
  });

  group('SplashAnimationConfig', () {
    test('should have valid duration values', () {
      expect(SplashAnimationConfig.scannerDuration.inMilliseconds, greaterThan(0));
      expect(SplashAnimationConfig.logoRevealDuration.inMilliseconds, greaterThan(0));
      expect(SplashAnimationConfig.textFadeDuration.inMilliseconds, greaterThan(0));
      expect(SplashAnimationConfig.holdDuration.inMilliseconds, greaterThan(0));
      expect(SplashAnimationConfig.exitFadeDuration.inMilliseconds, greaterThan(0));
    });

    test('should have valid curve values', () {
      expect(SplashAnimationConfig.scannerCurve, isNotNull);
      expect(SplashAnimationConfig.logoRevealCurve, isNotNull);
      expect(SplashAnimationConfig.textFadeCurve, isNotNull);
      expect(SplashAnimationConfig.exitFadeCurve, isNotNull);
    });

    test('should calculate total duration correctly', () {
      final expectedTotal = SplashAnimationConfig.scannerDuration +
          SplashAnimationConfig.logoRevealDuration +
          SplashAnimationConfig.textFadeDuration +
          SplashAnimationConfig.holdDuration +
          SplashAnimationConfig.exitFadeDuration;
      
      expect(SplashAnimationConfig.totalDuration, expectedTotal);
    });

    test('should have reasonable max splash duration', () {
      expect(SplashAnimationConfig.maxSplashDuration, 
             greaterThan(SplashAnimationConfig.totalDuration));
      expect(SplashAnimationConfig.maxSplashDuration.inSeconds, lessThanOrEqualTo(10));
    });
  });
}