import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/splash_theme_data.dart';
import '../controllers/splash_controller.dart';
import '../widgets/app_name_widget.dart';
import '../services/accessibility_service.dart';

/// Animated splash screen widget that displays during app initialization
class SplashScreen extends StatefulWidget {
  /// Callback triggered when animation completes
  final VoidCallback onAnimationComplete;
  
  /// Optional callback for error handling
  final Function(SplashErrorType, String)? onError;

  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
    this.onError,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late SplashThemeData _themeData;
  late SplashController _controller;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = SplashController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_hasInitialized) {
      _hasInitialized = true;
      
      try {
        // Extract theme colors when dependencies change (including theme changes)
        final highContrast = AccessibilityService.isHighContrastEnabled(context);
        _themeData = SplashThemeData.fromTheme(Theme.of(context), highContrast: highContrast);
        
        // Initialize controller with ticker provider, callbacks, and error handling
        _controller.initialize(
          this, 
          onComplete: widget.onAnimationComplete,
          onError: _handleSplashError,
          context: context,
        );
        
        // Start animation after first frame with error handling
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.isHealthy) {
            _controller.startAnimation();
          } else if (!_controller.isHealthy) {
            // Force complete if controller is not healthy
            _controller.forceComplete();
          }
        });
        
      } catch (e, stackTrace) {
        developer.log(
          'Failed to initialize splash screen: $e',
          name: 'SplashScreen',
          error: e,
          stackTrace: stackTrace,
        );
        
        // Fallback: navigate immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onAnimationComplete();
          }
        });
      }
    }
  }
  
  /// Handle splash screen errors
  void _handleSplashError(SplashErrorType errorType, String message) {
    developer.log(
      'Splash screen error: $errorType - $message',
      name: 'SplashScreen',
    );
    
    // Notify parent widget if error callback is provided
    widget.onError?.call(errorType, message);
    
    // For critical errors, force navigation to prevent stuck splash screen
    if (errorType == SplashErrorType.timeout || 
        errorType == SplashErrorType.animationFailure) {
      if (mounted) {
        widget.onAnimationComplete();
      }
    }
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (e) {
      developer.log('Error disposing splash controller: $e', name: 'SplashScreen');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update accessibility settings if they changed
    _controller.updateAccessibilitySettings(context);
    
    return Scaffold(
      backgroundColor: _themeData.backgroundColor,
      body: SafeArea(
        child: Semantics(
          label: _controller.reducedMotionEnabled 
              ? AccessibilityService.getReducedMotionDescription()
              : _controller.currentStateSemanticLabel,
          liveRegion: true,
          child: AnimatedBuilder(
            animation: _controller.exitFadeAnimation,
            builder: (context, child) {
              try {
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
                      child: _SplashContent(
                        controller: _controller,
                        themeData: _themeData,
                      ),
                    ),
                  ),
                );
              } catch (e) {
                developer.log('Error building splash screen: $e', name: 'SplashScreen');
                
                // Fallback UI in case of rendering errors
                return Semantics(
                  label: 'ScanFlow app loading, please wait',
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: _themeData.backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Centered content area for splash screen elements
class _SplashContent extends StatelessWidget {
  /// The splash controller managing animations
  final SplashController controller;
  
  /// Theme data for accessibility-aware styling
  final SplashThemeData themeData;
  
  const _SplashContent({
    required this.controller,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = controller.highContrastEnabled;
    final isReducedMotion = controller.reducedMotionEnabled;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo area with accessibility support
        Semantics(
          label: 'ScanFlow logo',
          image: true,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isHighContrast 
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: isHighContrast 
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: AnimatedBuilder(
              animation: controller.logoRevealAnimation,
              builder: (context, child) {
                // For reduced motion, show static icon
                if (isReducedMotion) {
                  return Icon(
                    Icons.scanner,
                    size: 60,
                    color: isHighContrast 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary,
                  );
                }
                
                // Animated reveal for normal motion
                return Opacity(
                  opacity: controller.logoRevealAnimation.value,
                  child: Transform.scale(
                    scale: 0.8 + (controller.logoRevealAnimation.value * 0.2),
                    child: Icon(
                      Icons.scanner,
                      size: 60,
                      color: isHighContrast 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Animated app name text with accessibility support
        AppNameWidget(
          controller: controller,
          themeData: themeData,
        ),
      ],
    );
  }
}