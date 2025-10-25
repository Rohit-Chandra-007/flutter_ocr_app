import 'package:flutter/material.dart';

/// Animated logo widget with fallback
class AnimatedLogo extends StatelessWidget {
  final bool isDark;
  final Animation<double> scaleAnimation;
  final Animation<double> rotateAnimation;

  const AnimatedLogo({
    super.key,
    required this.isDark,
    required this.scaleAnimation,
    required this.rotateAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Transform.rotate(
      angle: rotateAnimation.value,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
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
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
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
