import 'package:flutter/material.dart';
import '../../animations/splash_animations.dart';
import 'animated_logo.dart';
import 'app_branding.dart';

/// Composed splash logo with animations
class SplashLogo extends StatelessWidget {
  final SplashAnimationBundle animations;
  final bool isDark;

  const SplashLogo({
    super.key,
    required this.animations,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animations.controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: animations.fade,
          child: Transform.translate(
            offset: Offset(0, animations.slide.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedLogo(
                  isDark: isDark,
                  scaleAnimation: animations.scale,
                  rotateAnimation: animations.rotate,
                ),
                const SizedBox(height: 48),
                AppBranding(
                  taglineFadeAnimation: animations.taglineFade,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
