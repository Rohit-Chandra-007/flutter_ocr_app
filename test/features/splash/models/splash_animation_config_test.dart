import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/models/splash_animation_config.dart';

void main() {
  group('SplashAnimationConfig', () {
    group('Duration Constants', () {
      test('should have positive duration values', () {
        expect(SplashAnimationConfig.scannerDuration.inMilliseconds, greaterThan(0));
        expect(SplashAnimationConfig.logoRevealDuration.inMilliseconds, greaterThan(0));
        expect(SplashAnimationConfig.textFadeDuration.inMilliseconds, greaterThan(0));
        expect(SplashAnimationConfig.holdDuration.inMilliseconds, greaterThan(0));
        expect(SplashAnimationConfig.exitFadeDuration.inMilliseconds, greaterThan(0));
      });

      test('should have reasonable duration values', () {
        // Scanner animation should be the longest individual phase
        expect(SplashAnimationConfig.scannerDuration.inMilliseconds, 
               equals(1500));
        expect(SplashAnimationConfig.logoRevealDuration.inMilliseconds, 
               equals(800));
        expect(SplashAnimationConfig.textFadeDuration.inMilliseconds, 
               equals(600));
        expect(SplashAnimationConfig.holdDuration.inMilliseconds, 
               equals(1000));
        expect(SplashAnimationConfig.exitFadeDuration.inMilliseconds, 
               equals(400));
      });

      test('should have max splash duration greater than total duration', () {
        expect(SplashAnimationConfig.maxSplashDuration, 
               greaterThan(SplashAnimationConfig.totalDuration));
        expect(SplashAnimationConfig.maxSplashDuration.inSeconds, equals(5));
      });
    });

    group('Animation Curves', () {
      test('should have valid curve constants', () {
        expect(SplashAnimationConfig.scannerCurve, equals(Curves.easeInOut));
        expect(SplashAnimationConfig.logoRevealCurve, equals(Curves.easeOut));
        expect(SplashAnimationConfig.textFadeCurve, equals(Curves.easeIn));
        expect(SplashAnimationConfig.exitFadeCurve, equals(Curves.easeInOut));
      });

      test('should use appropriate curves for each animation phase', () {
        // Scanner should use easeInOut for smooth start and end
        expect(SplashAnimationConfig.scannerCurve, equals(Curves.easeInOut));
        
        // Logo reveal should ease out for natural appearance
        expect(SplashAnimationConfig.logoRevealCurve, equals(Curves.easeOut));
        
        // Text fade should ease in for subtle appearance
        expect(SplashAnimationConfig.textFadeCurve, equals(Curves.easeIn));
        
        // Exit fade should be smooth both ways
        expect(SplashAnimationConfig.exitFadeCurve, equals(Curves.easeInOut));
      });
    });

    group('Total Duration Calculation', () {
      test('should calculate total duration correctly', () {
        final expectedTotal = 
            SplashAnimationConfig.scannerDuration.inMilliseconds +
            SplashAnimationConfig.logoRevealDuration.inMilliseconds +
            SplashAnimationConfig.textFadeDuration.inMilliseconds +
            SplashAnimationConfig.holdDuration.inMilliseconds +
            SplashAnimationConfig.exitFadeDuration.inMilliseconds;
        
        expect(SplashAnimationConfig.totalDuration.inMilliseconds, 
               equals(expectedTotal));
      });

      test('should have total duration of 4.3 seconds', () {
        // 1500 + 800 + 600 + 1000 + 400 = 4300ms = 4.3s
        expect(SplashAnimationConfig.totalDuration.inMilliseconds, equals(4300));
        expect(SplashAnimationConfig.totalDuration.inSeconds, equals(4));
      });
    });

    group('Animation Intervals', () {
      test('should calculate scanner end interval correctly', () {
        final expected = SplashAnimationConfig.scannerDuration.inMilliseconds / 
                        SplashAnimationConfig.totalDuration.inMilliseconds;
        expect(SplashAnimationConfig.scannerEndInterval, equals(expected));
        expect(SplashAnimationConfig.scannerEndInterval, closeTo(0.349, 0.001));
      });

      test('should calculate logo reveal end interval correctly', () {
        final expected = (SplashAnimationConfig.scannerDuration.inMilliseconds + 
                         SplashAnimationConfig.logoRevealDuration.inMilliseconds) / 
                        SplashAnimationConfig.totalDuration.inMilliseconds;
        expect(SplashAnimationConfig.logoRevealEndInterval, equals(expected));
        expect(SplashAnimationConfig.logoRevealEndInterval, closeTo(0.535, 0.001));
      });

      test('should calculate text fade end interval correctly', () {
        final expected = (SplashAnimationConfig.scannerDuration.inMilliseconds + 
                         SplashAnimationConfig.logoRevealDuration.inMilliseconds +
                         SplashAnimationConfig.textFadeDuration.inMilliseconds) / 
                        SplashAnimationConfig.totalDuration.inMilliseconds;
        expect(SplashAnimationConfig.textFadeEndInterval, equals(expected));
        expect(SplashAnimationConfig.textFadeEndInterval, closeTo(0.674, 0.001));
      });

      test('should calculate hold end interval correctly', () {
        final expected = (SplashAnimationConfig.scannerDuration.inMilliseconds + 
                         SplashAnimationConfig.logoRevealDuration.inMilliseconds +
                         SplashAnimationConfig.textFadeDuration.inMilliseconds +
                         SplashAnimationConfig.holdDuration.inMilliseconds) / 
                        SplashAnimationConfig.totalDuration.inMilliseconds;
        expect(SplashAnimationConfig.holdEndInterval, equals(expected));
        expect(SplashAnimationConfig.holdEndInterval, closeTo(0.907, 0.001));
      });

      test('should have intervals in ascending order', () {
        expect(SplashAnimationConfig.scannerEndInterval, 
               lessThan(SplashAnimationConfig.logoRevealEndInterval));
        expect(SplashAnimationConfig.logoRevealEndInterval, 
               lessThan(SplashAnimationConfig.textFadeEndInterval));
        expect(SplashAnimationConfig.textFadeEndInterval, 
               lessThan(SplashAnimationConfig.holdEndInterval));
        expect(SplashAnimationConfig.holdEndInterval, lessThan(1.0));
      });

      test('should have all intervals between 0.0 and 1.0', () {
        expect(SplashAnimationConfig.scannerEndInterval, 
               allOf(greaterThan(0.0), lessThan(1.0)));
        expect(SplashAnimationConfig.logoRevealEndInterval, 
               allOf(greaterThan(0.0), lessThan(1.0)));
        expect(SplashAnimationConfig.textFadeEndInterval, 
               allOf(greaterThan(0.0), lessThan(1.0)));
        expect(SplashAnimationConfig.holdEndInterval, 
               allOf(greaterThan(0.0), lessThan(1.0)));
      });
    });

    group('Performance Considerations', () {
      test('should have reasonable animation durations for 60fps', () {
        // Each phase should be long enough for smooth animation at 60fps
        // Minimum ~100ms for noticeable animation
        expect(SplashAnimationConfig.scannerDuration.inMilliseconds, 
               greaterThanOrEqualTo(100));
        expect(SplashAnimationConfig.logoRevealDuration.inMilliseconds, 
               greaterThanOrEqualTo(100));
        expect(SplashAnimationConfig.textFadeDuration.inMilliseconds, 
               greaterThanOrEqualTo(100));
        expect(SplashAnimationConfig.exitFadeDuration.inMilliseconds, 
               greaterThanOrEqualTo(100));
      });

      test('should not exceed reasonable total duration', () {
        // Total animation should not be too long to avoid user frustration
        expect(SplashAnimationConfig.totalDuration.inSeconds, 
               lessThanOrEqualTo(6));
      });

      test('should have appropriate hold duration', () {
        // Hold duration should be long enough to read but not too long
        expect(SplashAnimationConfig.holdDuration.inMilliseconds, 
               allOf(greaterThanOrEqualTo(500), lessThanOrEqualTo(2000)));
      });
    });
  });
}