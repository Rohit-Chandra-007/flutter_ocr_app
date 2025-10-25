import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scanflow/core/core.dart';

import '../../animations/splash_animations.dart';
import '../widgets/splash_logo.dart';

/// Simple splash screen that displays app logo and navigates to home
class SplashScreen extends StatefulWidget {
  /// Callback triggered when splash completes
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashAnimationBundle _animations;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animations = SplashAnimations.build(this);
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    
    _animations.controller.forward();

    // Initialize app resources in parallel with animation
    final initFuture = AppInitializationService.initialize();

    
    final results = await Future.wait([
      initFuture,
      Future.delayed(AppConstants.splashSequence),
    ]);

    final success = results[0] as bool;

    if (!success) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = AppInitializationService.getUserFriendlyError();
        });
      }
      return;
    }

    if (mounted) {
      widget.onComplete(); // Callback to navigate
    }
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.white,
      body: Center(
        child: _hasError
            ? _buildErrorState(theme)
            : SplashLogo(
                animations: _animations,
                isDark: isDark,
              ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Initialization Failed',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
              });
              _startSplashSequence();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
