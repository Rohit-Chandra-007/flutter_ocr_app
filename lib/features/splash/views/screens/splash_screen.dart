import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../animations/splash_animations.dart';
import '../../viewmodels/splash_provider.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_error_view.dart';

/// Splash screen with initialization logic
class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashAnimationBundle _animations;

  @override
  void initState() {
    super.initState();
    _animations = SplashAnimations.build(this);
    _animations.controller.forward();
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
    final splashState = ref.watch(splashProvider);

    // Trigger navigation when initialization completes
    ref.listen(splashProvider, (previous, next) {
      if (!next.isLoading && !next.hasError) {
        widget.onComplete();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.white,
      body: Center(
        child: splashState.hasError
            ? SplashErrorView(
                message: splashState.errorMessage,
                onRetry: () => ref.read(splashProvider.notifier).retry(),
              )
            : SplashLogo(
                animations: _animations,
                isDark: isDark,
              ),
      ),
    );
  }
}
