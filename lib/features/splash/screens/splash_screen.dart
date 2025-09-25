import 'package:flutter/material.dart';
import '../models/splash_theme_data.dart';
import '../controllers/splash_controller.dart';
import '../widgets/app_name_widget.dart';

/// Animated splash screen widget that displays during app initialization
class SplashScreen extends StatefulWidget {
  /// Callback triggered when animation completes
  final VoidCallback onAnimationComplete;

  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late SplashThemeData _themeData;
  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract theme colors when dependencies change (including theme changes)
    _themeData = SplashThemeData.fromTheme(Theme.of(context));
    
    // Initialize controller with ticker provider and callback
    _controller.initialize(this, onComplete: widget.onAnimationComplete);
    
    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startAnimation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeData.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller.exitFadeAnimation,
          builder: (context, child) {
            // Use exit fade animation for seamless transition
            final opacity = _controller.exitFadeAnimation.value;
            
            return Opacity(
              opacity: opacity,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: _themeData.backgroundColor,
                ),
                child: Center(
                  child: _SplashContent(controller: _controller),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Centered content area for splash screen elements
class _SplashContent extends StatelessWidget {
  /// The splash controller managing animations
  final SplashController controller;
  
  const _SplashContent({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Placeholder for logo animation area
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.scanner,
            size: 60,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Animated app name text
        AppNameWidget(controller: controller),
      ],
    );
  }
}