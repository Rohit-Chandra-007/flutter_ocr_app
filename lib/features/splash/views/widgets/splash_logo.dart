import 'package:flutter/material.dart';

import '../../animations/splash_animations.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.animations,
    required this.isDark,
  });

  final SplashAnimationBundle animations;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: animations.controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: animations.fade,
          child: Transform.translate(
            offset: Offset(0, animations.slide.value),
            child: Transform.rotate(
              angle: animations.rotate.value,
              child: ScaleTransition(
                scale: animations.scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(theme),
                    const SizedBox(height: 48),
                    _buildAppName(theme),
                    const SizedBox(height: 16),
                    _buildTagline(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          isDark
              ? 'assets/icons/scanflow_logo_dark.png'
              : 'assets/icons/scanflow_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
        ),
      ),
    );
  }

  Widget _buildAppName(ThemeData theme) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF1E3A8A),
          Color(0xFF3B82F6),
        ],
      ).createShader(bounds),
      child: Text(
        'ScanFlow',
        style: theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTagline(ThemeData theme) {
    return FadeTransition(
      opacity: animations.taglineFade,
      child: Text(
        'Scan. Organize. Simplify.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Icon(
        Icons.document_scanner_rounded,
        size: 100,
        color: Colors.white,
      ),
    );
  }
}
