import 'package:flutter/material.dart';
import '../controllers/splash_controller.dart';

/// Widget that displays the app name with fade-in animation
class AppNameWidget extends StatelessWidget {
  /// The splash controller managing the animation
  final SplashController controller;
  
  const AppNameWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: controller.textFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: controller.textFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - controller.textFadeAnimation.value) * 10),
            child: Text(
              'ScanFlow',
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}