import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/models/splash_animation_config.dart';

void main() {
  group('SplashAnimationConfig Accessibility', () {
    test('should provide correct durations for normal motion', () {
      // Act & Assert
      expect(
        SplashAnimationConfig.getScannerDuration(false),
        SplashAnimationConfig.scannerDuration,
      );
      expect(
        SplashAnimationConfig.getLogoRevealDuration(false),
        SplashAnimationConfig.logoRevealDuration,
      );
      expect(
        SplashAnimationConfig.getTextFadeDuration(false),
        SplashAnimationConfig.textFadeDuration,
      );
      expect(
        SplashAnimationConfig.getHoldDuration(false),
        SplashAnimationConfig.holdDuration,
      );
      expect(
        SplashAnimationConfig.getExitFadeDuration(false),
        SplashAnimationConfig.exitFadeDuration,
      );
      expect(
        SplashAnimationConfig.getTotalDuration(false),
        SplashAnimationConfig.totalDuration,
      );
    });

    test('should provide correct durations for reduced motion', () {
      // Act & Assert
      expect(
        SplashAnimationConfig.getScannerDuration(true),
        SplashAnimationConfig.reducedScannerDuration,
      );
      expect(
        SplashAnimationConfig.getLogoRevealDuration(true),
        SplashAnimationConfig.reducedLogoRevealDuration,
      );
      expect(
        SplashAnimationConfig.getTextFadeDuration(true),
        SplashAnimationConfig.reducedTextFadeDuration,
      );
      expect(
        SplashAnimationConfig.getHoldDuration(true),
        SplashAnimationConfig.reducedHoldDuration,
      );
      expect(
        SplashAnimationConfig.getExitFadeDuration(true),
        SplashAnimationConfig.reducedExitFadeDuration,
      );
      expect(
        SplashAnimationConfig.getTotalDuration(true),
        SplashAnimationConfig.reducedTotalDuration,
      );
    });

    test('should have shorter durations for reduced motion', () {
      // Assert - Reduced motion durations should be shorter
      expect(
        SplashAnimationConfig.reducedScannerDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.scannerDuration.inMilliseconds),
      );
      expect(
        SplashAnimationConfig.reducedLogoRevealDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.logoRevealDuration.inMilliseconds),
      );
      expect(
        SplashAnimationConfig.reducedTextFadeDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.textFadeDuration.inMilliseconds),
      );
      expect(
        SplashAnimationConfig.reducedHoldDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.holdDuration.inMilliseconds),
      );
      expect(
        SplashAnimationConfig.reducedExitFadeDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.exitFadeDuration.inMilliseconds),
      );
      expect(
        SplashAnimationConfig.reducedTotalDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.totalDuration.inMilliseconds),
      );
    });

    test('should provide correct intervals for normal motion', () {
      // Act
      final scannerEnd = SplashAnimationConfig.getScannerEndInterval(false);
      final logoRevealEnd = SplashAnimationConfig.getLogoRevealEndInterval(false);
      final textFadeEnd = SplashAnimationConfig.getTextFadeEndInterval(false);
      final holdEnd = SplashAnimationConfig.getHoldEndInterval(false);

      // Assert - Intervals should be in correct order and within 0.0 to 1.0
      expect(scannerEnd, greaterThan(0.0));
      expect(scannerEnd, lessThan(1.0));
      expect(logoRevealEnd, greaterThan(scannerEnd));
      expect(logoRevealEnd, lessThan(1.0));
      expect(textFadeEnd, greaterThan(logoRevealEnd));
      expect(textFadeEnd, lessThan(1.0));
      expect(holdEnd, greaterThan(textFadeEnd));
      expect(holdEnd, lessThan(1.0));
    });

    test('should provide correct intervals for reduced motion', () {
      // Act
      final scannerEnd = SplashAnimationConfig.getScannerEndInterval(true);
      final logoRevealEnd = SplashAnimationConfig.getLogoRevealEndInterval(true);
      final textFadeEnd = SplashAnimationConfig.getTextFadeEndInterval(true);
      final holdEnd = SplashAnimationConfig.getHoldEndInterval(true);

      // Assert - Intervals should be in correct order and within 0.0 to 1.0
      expect(scannerEnd, greaterThan(0.0));
      expect(scannerEnd, lessThan(1.0));
      expect(logoRevealEnd, greaterThan(scannerEnd));
      expect(logoRevealEnd, lessThan(1.0));
      expect(textFadeEnd, greaterThan(logoRevealEnd));
      expect(textFadeEnd, lessThan(1.0));
      expect(holdEnd, greaterThan(textFadeEnd));
      expect(holdEnd, lessThan(1.0));
    });

    test('should calculate intervals correctly based on durations', () {
      // Test normal motion intervals
      final normalTotal = SplashAnimationConfig.getTotalDuration(false);
      final expectedScannerEnd = SplashAnimationConfig.getScannerDuration(false).inMilliseconds / 
                                 normalTotal.inMilliseconds;
      
      expect(
        SplashAnimationConfig.getScannerEndInterval(false),
        closeTo(expectedScannerEnd, 0.001),
      );

      // Test reduced motion intervals
      final reducedTotal = SplashAnimationConfig.getTotalDuration(true);
      final expectedReducedScannerEnd = SplashAnimationConfig.getScannerDuration(true).inMilliseconds / 
                                       reducedTotal.inMilliseconds;
      
      expect(
        SplashAnimationConfig.getScannerEndInterval(true),
        closeTo(expectedReducedScannerEnd, 0.001),
      );
    });

    test('should have consistent total duration calculation', () {
      // Test normal motion
      final normalCalculated = SplashAnimationConfig.scannerDuration +
                              SplashAnimationConfig.logoRevealDuration +
                              SplashAnimationConfig.textFadeDuration +
                              SplashAnimationConfig.holdDuration +
                              SplashAnimationConfig.exitFadeDuration;
      
      expect(SplashAnimationConfig.totalDuration, normalCalculated);

      // Test reduced motion
      final reducedCalculated = SplashAnimationConfig.reducedScannerDuration +
                               SplashAnimationConfig.reducedLogoRevealDuration +
                               SplashAnimationConfig.reducedTextFadeDuration +
                               SplashAnimationConfig.reducedHoldDuration +
                               SplashAnimationConfig.reducedExitFadeDuration;
      
      expect(SplashAnimationConfig.reducedTotalDuration, reducedCalculated);
    });

    test('should have reasonable duration values', () {
      // Normal durations should be reasonable (not too short or too long)
      expect(SplashAnimationConfig.totalDuration.inMilliseconds, greaterThan(1000));
      expect(SplashAnimationConfig.totalDuration.inMilliseconds, lessThan(10000));

      // Reduced durations should be reasonable
      expect(SplashAnimationConfig.reducedTotalDuration.inMilliseconds, greaterThan(500));
      expect(SplashAnimationConfig.reducedTotalDuration.inMilliseconds, lessThan(5000));

      // Reduced duration should be significantly shorter than normal
      expect(
        SplashAnimationConfig.reducedTotalDuration.inMilliseconds,
        lessThan(SplashAnimationConfig.totalDuration.inMilliseconds * 0.5),
      );
    });
  });
}