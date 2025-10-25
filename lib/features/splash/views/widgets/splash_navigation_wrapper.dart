import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow/features/home/views/screens/home_screen.dart';
import '../screens/splash_screen.dart';

/// Navigation wrapper that shows splash then navigates to home
class SplashNavigationWrapper extends ConsumerStatefulWidget {
  const SplashNavigationWrapper({super.key});

  @override
  ConsumerState<SplashNavigationWrapper> createState() =>
      _SplashNavigationWrapperState();
}

class _SplashNavigationWrapperState
    extends ConsumerState<SplashNavigationWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onComplete: _onSplashComplete,
            )
          : const HomeScreen(
              key: ValueKey('home'),
            ),
    );
  }
}