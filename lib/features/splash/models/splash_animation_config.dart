import 'package:flutter/material.dart';

/// Configuration class for splash screen animation timing and curves
class SplashAnimationConfig {
  // Animation Durations
  static const Duration scannerDuration = Duration(milliseconds: 1500);
  static const Duration logoRevealDuration = Duration(milliseconds: 800);
  static const Duration textFadeDuration = Duration(milliseconds: 600);
  static const Duration holdDuration = Duration(milliseconds: 1000);
  static const Duration exitFadeDuration = Duration(milliseconds: 400);
  
  // Animation Curves
  static const Curve scannerCurve = Curves.easeInOut;
  static const Curve logoRevealCurve = Curves.easeOut;
  static const Curve textFadeCurve = Curves.easeIn;
  static const Curve exitFadeCurve = Curves.easeInOut;
  
  // Total animation duration calculation
  static Duration get totalDuration => 
      scannerDuration + logoRevealDuration + textFadeDuration + holdDuration + exitFadeDuration;
  
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
}