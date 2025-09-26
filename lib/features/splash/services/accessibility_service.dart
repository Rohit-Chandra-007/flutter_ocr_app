import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for handling accessibility features and preferences
class AccessibilityService {
  /// Check if reduced motion is enabled in system settings
  static bool isReducedMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
  
  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }
  
  /// Get accessibility timeout for animations
  static Duration getAccessibilityTimeout(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    // If any accessibility features are enabled, use shorter timeout
    if (mediaQuery.disableAnimations ||
        mediaQuery.boldText ||
        mediaQuery.highContrast) {
      return const Duration(milliseconds: 500);
    }
    
    return const Duration(milliseconds: 2000);
  }
  
  /// Provide haptic feedback for accessibility
  static void provideAccessibilityFeedback() {
    HapticFeedback.lightImpact();
  }
  
  /// Get semantic label for splash screen state
  static String getSplashStateSemanticLabel(String state) {
    switch (state) {
      case 'scanning':
        return 'ScanFlow app is loading, scanning animation in progress';
      case 'revealingLogo':
        return 'ScanFlow logo appearing';
      case 'fadingInText':
        return 'ScanFlow app name appearing';
      case 'holding':
        return 'ScanFlow app loaded successfully';
      case 'exiting':
        return 'Transitioning to main app';
      default:
        return 'ScanFlow app is starting';
    }
  }
  
  /// Get reduced motion alternative description
  static String getReducedMotionDescription() {
    return 'ScanFlow app loading screen. Animations are reduced for accessibility.';
  }
  
  /// Check if screen reader is active
  static bool isScreenReaderActive(BuildContext context) {
    // In Flutter, we can use disableAnimations as a proxy for screen reader activity
    // This is not perfect but is the best available indicator
    return MediaQuery.of(context).disableAnimations;
  }
}