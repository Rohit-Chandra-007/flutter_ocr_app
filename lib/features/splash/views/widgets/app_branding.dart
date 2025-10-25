import 'package:flutter/material.dart';

/// App name and tagline branding
class AppBranding extends StatelessWidget {
  final Animation<double> taglineFadeAnimation;

  const AppBranding({
    super.key,
    required this.taglineFadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildAppName(theme),
        const SizedBox(height: 16),
        _buildTagline(theme),
      ],
    );
  }

  Widget _buildAppName(ThemeData theme) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
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
      opacity: taglineFadeAnimation,
      child: Text(
        'Scan. Organize. Simplify.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
