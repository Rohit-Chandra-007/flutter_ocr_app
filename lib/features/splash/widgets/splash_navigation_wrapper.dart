import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../../scan_history/screens/home_screen.dart';

/// Simple navigation wrapper that shows splash then navigates to home
class SplashNavigationWrapper extends StatefulWidget {
  const SplashNavigationWrapper({super.key});

  @override
  State<SplashNavigationWrapper> createState() => _SplashNavigationWrapperState();
}

class _SplashNavigationWrapperState extends State<SplashNavigationWrapper> {
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