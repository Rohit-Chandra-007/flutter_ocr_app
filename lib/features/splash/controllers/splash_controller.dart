import 'dart:async';
import 'package:flutter/material.dart';
import '../models/splash_animation_config.dart';

/// Animation states for the splash screen
enum SplashAnimationState {
  idle,
  scanning,
  revealingLogo,
  fadingInText,
  holding,
  exiting,
  completed,
  error,
}

/// Controller for managing splash screen animations and state
class SplashController extends ChangeNotifier {
  late AnimationController _mainController;
  late Animation<double> _scannerAnimation;
  late Animation<double> _logoRevealAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _exitFadeAnimation;
  
  Timer? _timeoutTimer;
  SplashAnimationState _currentState = SplashAnimationState.idle;
  VoidCallback? _onAnimationComplete;
  
  // Animation getters
  Animation<double> get scannerAnimation => _scannerAnimation;
  Animation<double> get logoRevealAnimation => _logoRevealAnimation;
  Animation<double> get textFadeAnimation => _textFadeAnimation;
  Animation<double> get exitFadeAnimation => _exitFadeAnimation;
  
  // State getters
  SplashAnimationState get currentState => _currentState;
  bool get isAnimating => _currentState != SplashAnimationState.idle && 
                         _currentState != SplashAnimationState.completed &&
                         _currentState != SplashAnimationState.error;
  
  /// Initialize the controller with the provided TickerProvider
  void initialize(TickerProvider tickerProvider, {VoidCallback? onComplete}) {
    _onAnimationComplete = onComplete;
    
    // Create main animation controller
    _mainController = AnimationController(
      duration: SplashAnimationConfig.totalDuration,
      vsync: tickerProvider,
    );
    
    // Set up animation sequences
    _setupAnimations();
    
    // Add animation listener for state management
    _mainController.addListener(_handleAnimationProgress);
    _mainController.addStatusListener(_handleAnimationStatus);
    
    // Set up timeout protection
    _setupTimeoutProtection();
  }
  
  /// Set up individual animation sequences with proper intervals
  void _setupAnimations() {
    // Scanner line animation (0.0 to scannerEndInterval)
    _scannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          0.0,
          SplashAnimationConfig.scannerEndInterval,
          curve: SplashAnimationConfig.scannerCurve,
        ),
      ),
    );
    
    // Logo reveal animation (scannerEndInterval to logoRevealEndInterval)
    _logoRevealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          SplashAnimationConfig.scannerEndInterval,
          SplashAnimationConfig.logoRevealEndInterval,
          curve: SplashAnimationConfig.logoRevealCurve,
        ),
      ),
    );
    
    // Text fade-in animation (logoRevealEndInterval to textFadeEndInterval)
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          SplashAnimationConfig.logoRevealEndInterval,
          SplashAnimationConfig.textFadeEndInterval,
          curve: SplashAnimationConfig.textFadeCurve,
        ),
      ),
    );
    
    // Exit fade animation (holdEndInterval to 1.0)
    _exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          SplashAnimationConfig.holdEndInterval,
          1.0,
          curve: SplashAnimationConfig.exitFadeCurve,
        ),
      ),
    );
  }
  
  /// Handle animation progress and update state accordingly
  void _handleAnimationProgress() {
    final progress = _mainController.value;
    final previousState = _currentState;
    
    if (progress <= SplashAnimationConfig.scannerEndInterval) {
      _updateState(SplashAnimationState.scanning);
    } else if (progress <= SplashAnimationConfig.logoRevealEndInterval) {
      _updateState(SplashAnimationState.revealingLogo);
    } else if (progress <= SplashAnimationConfig.textFadeEndInterval) {
      _updateState(SplashAnimationState.fadingInText);
    } else if (progress <= SplashAnimationConfig.holdEndInterval) {
      _updateState(SplashAnimationState.holding);
    } else {
      _updateState(SplashAnimationState.exiting);
      
      // Trigger callback when exit fade starts for seamless transition
      if (previousState != SplashAnimationState.exiting && _onAnimationComplete != null) {
        _onAnimationComplete?.call();
        _onAnimationComplete = null; // Prevent multiple calls
      }
    }
  }
  
  /// Handle animation status changes
  void _handleAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _updateState(SplashAnimationState.completed);
        _completeAnimation();
        break;
      case AnimationStatus.dismissed:
        _updateState(SplashAnimationState.idle);
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        // State is handled by progress listener
        break;
    }
  }
  
  /// Update the current animation state
  void _updateState(SplashAnimationState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      notifyListeners();
    }
  }
  
  /// Set up timeout protection to prevent infinite splash screen
  void _setupTimeoutProtection() {
    _timeoutTimer = Timer(SplashAnimationConfig.maxSplashDuration, () {
      if (isAnimating) {
        _handleTimeout();
      }
    });
  }
  
  /// Handle timeout scenario
  void _handleTimeout() {
    _updateState(SplashAnimationState.error);
    _completeAnimation();
  }
  
  /// Start the splash animation sequence
  void startAnimation() {
    if (_currentState == SplashAnimationState.idle) {
      _mainController.forward();
    }
  }
  
  /// Skip to the end of animation (for testing or user interaction)
  void skipAnimation() {
    _mainController.animateTo(1.0, duration: const Duration(milliseconds: 200));
  }
  
  /// Reset animation to initial state
  void resetAnimation() {
    _mainController.reset();
    _updateState(SplashAnimationState.idle);
  }
  
  /// Complete the animation and trigger callback
  void _completeAnimation() {
    _timeoutTimer?.cancel();
    
    // Fallback callback trigger if not already called during exit phase
    if (_onAnimationComplete != null) {
      _onAnimationComplete?.call();
      _onAnimationComplete = null;
    }
  }
  
  /// Get the current progress for a specific animation phase
  double getPhaseProgress(SplashAnimationState phase) {
    switch (phase) {
      case SplashAnimationState.scanning:
        return _scannerAnimation.value;
      case SplashAnimationState.revealingLogo:
        return _logoRevealAnimation.value;
      case SplashAnimationState.fadingInText:
        return _textFadeAnimation.value;
      case SplashAnimationState.exiting:
        return _exitFadeAnimation.value;
      default:
        return 0.0;
    }
  }
  
  /// Check if a specific animation phase is active
  bool isPhaseActive(SplashAnimationState phase) {
    return _currentState == phase;
  }
  
  /// Get overall animation progress (0.0 to 1.0)
  double get overallProgress => _mainController.value;
  
  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _mainController.removeListener(_handleAnimationProgress);
    _mainController.removeStatusListener(_handleAnimationStatus);
    _mainController.dispose();
    super.dispose();
  }
}