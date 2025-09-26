import 'package:flutter/material.dart';

/// Configuration class for splash screen animation timing and curves
class SplashAnimationConfig {
  // Animation Durations - Standard
  static const Duration scannerDuration = Duration(milliseconds: 1500);
  static const Duration logoRevealDuration = Duration(milliseconds: 800);
  static const Duration textFadeDuration = Duration(milliseconds: 600);
  static const Duration holdDuration = Duration(milliseconds: 1000);
  static const Duration exitFadeDuration = Duration(milliseconds: 400);
  
  // Animation Durations - Reduced Motion (Accessibility)
  static const Duration reducedScannerDuration = Duration(milliseconds: 300);
  static const Duration reducedLogoRevealDuration = Duration(milliseconds: 200);
  static const Duration reducedTextFadeDuration = Duration(milliseconds: 200);
  static const Duration reducedHoldDuration = Duration(milliseconds: 500);
  static const Duration reducedExitFadeDuration = Duration(milliseconds: 200);
  
  // Animation Curves
  static const Curve scannerCurve = Curves.easeInOut;
  static const Curve logoRevealCurve = Curves.easeOut;
  static const Curve textFadeCurve = Curves.easeIn;
  static const Curve exitFadeCurve = Curves.easeInOut;
  
  // Total animation duration calculation
  static Duration get totalDuration => 
      scannerDuration + logoRevealDuration + textFadeDuration + holdDuration + exitFadeDuration;
  
  // Total animation duration for reduced motion
  static Duration get reducedTotalDuration => 
      reducedScannerDuration + reducedLogoRevealDuration + reducedTextFadeDuration + reducedHoldDuration + reducedExitFadeDuration;
  
  // Animation phase intervals (normalized 0.0 to 1.0)
  static double get scannerEndInterval => 
      scannerDuration.inMilliseconds / totalDuration.inMilliseconds;
  
  static double get logoRevealEndInterval => 
      (scannerDuration.inMilliseconds + logoRevealDuration.inMilliseconds) / totalDuration.inMilliseconds;
  
  static double get textFadeEndInterval => 
      (scannerDuration.inMilliseconds + logoRevealDuration.inMilliseconds + textFadeDuration.inMilliseconds) / totalDuration.inMilliseconds;
  
  static double get holdEndInterval => 
      (scannerDuration.inMilliseconds + logoRevealDuration.inMilliseconds + textFadeDuration.inMilliseconds + holdDuration.inMilliseconds) / totalDuration.inMilliseconds;
  
  // Maximum splash duration for timeout protection
  static const Duration maxSplashDuration = Duration(seconds: 5);
  
  /// Get animation durations based on accessibility preferences
  static Duration getScannerDuration(bool reducedMotion) => 
      reducedMotion ? reducedScannerDuration : scannerDuration;
  
  static Duration getLogoRevealDuration(bool reducedMotion) => 
      reducedMotion ? reducedLogoRevealDuration : logoRevealDuration;
  
  static Duration getTextFadeDuration(bool reducedMotion) => 
      reducedMotion ? reducedTextFadeDuration : textFadeDuration;
  
  static Duration getHoldDuration(bool reducedMotion) => 
      reducedMotion ? reducedHoldDuration : holdDuration;
  
  static Duration getExitFadeDuration(bool reducedMotion) => 
      reducedMotion ? reducedExitFadeDuration : exitFadeDuration;
  
  static Duration getTotalDuration(bool reducedMotion) => 
      reducedMotion ? reducedTotalDuration : totalDuration;
  
  /// Get animation intervals based on accessibility preferences
  static double getScannerEndInterval(bool reducedMotion) {
    final total = getTotalDuration(reducedMotion);
    return getScannerDuration(reducedMotion).inMilliseconds / total.inMilliseconds;
  }
  
  static double getLogoRevealEndInterval(bool reducedMotion) {
    final total = getTotalDuration(reducedMotion);
    return (getScannerDuration(reducedMotion).inMilliseconds + 
            getLogoRevealDuration(reducedMotion).inMilliseconds) / total.inMilliseconds;
  }
  
  static double getTextFadeEndInterval(bool reducedMotion) {
    final total = getTotalDuration(reducedMotion);
    return (getScannerDuration(reducedMotion).inMilliseconds + 
            getLogoRevealDuration(reducedMotion).inMilliseconds + 
            getTextFadeDuration(reducedMotion).inMilliseconds) / total.inMilliseconds;
  }
  
  static double getHoldEndInterval(bool reducedMotion) {
    final total = getTotalDuration(reducedMotion);
    return (getScannerDuration(reducedMotion).inMilliseconds + 
            getLogoRevealDuration(reducedMotion).inMilliseconds + 
            getTextFadeDuration(reducedMotion).inMilliseconds + 
            getHoldDuration(reducedMotion).inMilliseconds) / total.inMilliseconds;
  }
}