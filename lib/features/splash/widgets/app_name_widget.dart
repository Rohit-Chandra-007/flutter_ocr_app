import 'package:flutter/material.dart';
import '../controllers/splash_controller.dart';
import '../models/splash_theme_data.dart';

/// Widget that displays the app name with fade-in animation
class AppNameWidget extends StatelessWidget {
  /// The splash controller managing the animation
  final SplashController controller;
  
  /// Theme data for accessibility-aware styling
  final SplashThemeData themeData;
  
  const AppNameWidget({
    super.key,
    required this.controller,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = controller.highContrastEnabled;
    final isReducedMotion = controller.reducedMotionEnabled;
    final isBoldText = MediaQuery.of(context).boldText;
    
    return Semantics(
      label: 'ScanFlow app name',
      header: true,
      child: AnimatedBuilder(
        animation: controller.textFadeAnimation,
        builder: (context, child) {
          // For reduced motion, show static text
          if (isReducedMotion) {
            return Text(
              'ScanFlow',
              style: theme.textTheme.displayLarge?.copyWith(
                color: isHighContrast 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface,
                fontWeight: isBoldText ? FontWeight.w900 : FontWeight.w700,
                shadows: isHighContrast ? [
                  Shadow(
                    color: theme.colorScheme.surface,
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ] : null,
              ),
              textAlign: TextAlign.center,
            );
          }
          
          // Animated text for normal motion
          return Opacity(
            opacity: controller.textFadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - controller.textFadeAnimation.value) * 10),
              child: Text(
                'ScanFlow',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: isHighContrast 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface,
                  fontWeight: isBoldText ? FontWeight.w900 : FontWeight.w700,
                  shadows: isHighContrast ? [
                    Shadow(
                      color: theme.colorScheme.surface,
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ] : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}