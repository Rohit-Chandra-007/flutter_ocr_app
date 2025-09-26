import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/splash_animation_config.dart';
import '../services/accessibility_service.dart';

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
  timeout,
  resourceLoadingFailed,
}

/// Error types that can occur during splash screen
enum SplashErrorType {
  animationFailure,
  timeout,
  resourceLoadingFailure,
  memoryPressure,
  performanceDegradation,
}

/// Performance metrics for splash screen monitoring
class SplashPerformanceMetrics {
  final int frameCount;
  final double averageFrameTime;
  final int droppedFrames;
  final Duration totalDuration;
  final bool hadPerformanceIssues;
  
  const SplashPerformanceMetrics({
    required this.frameCount,
    required this.averageFrameTime,
    required this.droppedFrames,
    required this.totalDuration,
    required this.hadPerformanceIssues,
  });
}

/// Controller for managing splash screen animations and state
class SplashController extends ChangeNotifier {
  late AnimationController _mainController;
  late Animation<double> _scannerAnimation;
  late Animation<double> _logoRevealAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _exitFadeAnimation;
  
  Timer? _timeoutTimer;
  Timer? _performanceMonitorTimer;
  SplashAnimationState _currentState = SplashAnimationState.idle;
  VoidCallback? _onAnimationComplete;
  Function(SplashErrorType, String)? _onError;
  
  // Accessibility support
  bool _reducedMotionEnabled = false;
  bool _highContrastEnabled = false;
  bool _screenReaderActive = false;
  
  // Performance monitoring
  final List<Duration> _frameTimes = [];
  final Stopwatch _animationStopwatch = Stopwatch();
  int _droppedFrameCount = 0;
  bool _performanceIssuesDetected = false;
  bool _resourceLoadingFailed = false;
  
  // Error handling
  final List<String> _errorLog = [];
  bool _hasEncounteredError = false;
  
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
  
  // Accessibility getters
  bool get reducedMotionEnabled => _reducedMotionEnabled;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get screenReaderActive => _screenReaderActive;
  
  /// Initialize the controller with the provided TickerProvider
  void initialize(
    TickerProvider tickerProvider, {
    VoidCallback? onComplete,
    Function(SplashErrorType, String)? onError,
    BuildContext? context,
  }) {
    try {
      _onAnimationComplete = onComplete;
      _onError = onError;
      
      // Initialize accessibility settings
      if (context != null) {
        _initializeAccessibilitySettings(context);
      }
      
      // Create main animation controller with accessibility-aware duration
      _mainController = AnimationController(
        duration: SplashAnimationConfig.getTotalDuration(_reducedMotionEnabled),
        vsync: tickerProvider,
      );
      
      // Set up animation sequences
      _setupAnimations();
      
      // Add animation listener for state management
      _mainController.addListener(_handleAnimationProgress);
      _mainController.addStatusListener(_handleAnimationStatus);
      
      // Set up timeout protection
      _setupTimeoutProtection();
      
      // Set up performance monitoring
      _setupPerformanceMonitoring();
      
      // Preload resources with error handling
      _preloadResources();
      
    } catch (e, stackTrace) {
      _handleError(SplashErrorType.animationFailure, 
                  'Failed to initialize splash controller: $e', stackTrace);
    }
  }
  
  /// Initialize accessibility settings based on system preferences
  void _initializeAccessibilitySettings(BuildContext context) {
    _reducedMotionEnabled = AccessibilityService.isReducedMotionEnabled(context);
    _highContrastEnabled = AccessibilityService.isHighContrastEnabled(context);
    _screenReaderActive = AccessibilityService.isScreenReaderActive(context);
    
    developer.log(
      'Accessibility settings: reducedMotion=$_reducedMotionEnabled, '
      'highContrast=$_highContrastEnabled, screenReader=$_screenReaderActive',
      name: 'SplashController',
    );
  }
  
  /// Set up individual animation sequences with proper intervals
  void _setupAnimations() {
    // Get accessibility-aware intervals
    final scannerEndInterval = SplashAnimationConfig.getScannerEndInterval(_reducedMotionEnabled);
    final logoRevealEndInterval = SplashAnimationConfig.getLogoRevealEndInterval(_reducedMotionEnabled);
    final textFadeEndInterval = SplashAnimationConfig.getTextFadeEndInterval(_reducedMotionEnabled);
    final holdEndInterval = SplashAnimationConfig.getHoldEndInterval(_reducedMotionEnabled);
    
    // Scanner line animation (0.0 to scannerEndInterval)
    _scannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          0.0,
          scannerEndInterval,
          curve: _reducedMotionEnabled ? Curves.linear : SplashAnimationConfig.scannerCurve,
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
          scannerEndInterval,
          logoRevealEndInterval,
          curve: _reducedMotionEnabled ? Curves.linear : SplashAnimationConfig.logoRevealCurve,
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
          logoRevealEndInterval,
          textFadeEndInterval,
          curve: _reducedMotionEnabled ? Curves.linear : SplashAnimationConfig.textFadeCurve,
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
          holdEndInterval,
          1.0,
          curve: _reducedMotionEnabled ? Curves.linear : SplashAnimationConfig.exitFadeCurve,
        ),
      ),
    );
  }
  
  /// Handle animation progress and update state accordingly
  void _handleAnimationProgress() {
    try {
      final progress = _mainController.value;
      final previousState = _currentState;
      
      // Skip state updates if we've encountered an error
      if (_hasEncounteredError) return;
      
      // Get accessibility-aware intervals
      final scannerEndInterval = SplashAnimationConfig.getScannerEndInterval(_reducedMotionEnabled);
      final logoRevealEndInterval = SplashAnimationConfig.getLogoRevealEndInterval(_reducedMotionEnabled);
      final textFadeEndInterval = SplashAnimationConfig.getTextFadeEndInterval(_reducedMotionEnabled);
      final holdEndInterval = SplashAnimationConfig.getHoldEndInterval(_reducedMotionEnabled);
      
      if (progress <= scannerEndInterval) {
        _updateState(SplashAnimationState.scanning);
      } else if (progress <= logoRevealEndInterval) {
        _updateState(SplashAnimationState.revealingLogo);
      } else if (progress <= textFadeEndInterval) {
        _updateState(SplashAnimationState.fadingInText);
      } else if (progress <= holdEndInterval) {
        _updateState(SplashAnimationState.holding);
      } else {
        _updateState(SplashAnimationState.exiting);
        
        // Trigger callback when exit fade starts for seamless transition
        if (previousState != SplashAnimationState.exiting && _onAnimationComplete != null) {
          _onAnimationComplete?.call();
          _onAnimationComplete = null; // Prevent multiple calls
        }
      }
      
    } catch (e, stackTrace) {
      _handleError(
        SplashErrorType.animationFailure,
        'Animation progress handling failed: $e',
        stackTrace,
      );
    }
  }
  
  /// Handle animation status changes
  void _handleAnimationStatus(AnimationStatus status) {
    try {
      switch (status) {
        case AnimationStatus.completed:
          if (!_hasEncounteredError) {
            _updateState(SplashAnimationState.completed);
            _completeAnimation();
          }
          break;
        case AnimationStatus.dismissed:
          if (!_hasEncounteredError) {
            _updateState(SplashAnimationState.idle);
          }
          break;
        case AnimationStatus.forward:
          // Start timing when animation begins
          if (!_animationStopwatch.isRunning) {
            _animationStopwatch.start();
          }
          break;
        case AnimationStatus.reverse:
          // State is handled by progress listener
          break;
      }
    } catch (e, stackTrace) {
      _handleError(
        SplashErrorType.animationFailure,
        'Animation status handling failed: $e',
        stackTrace,
      );
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
      if (isAnimating && !_hasEncounteredError) {
        _handleTimeout();
      }
    });
  }
  
  /// Set up performance monitoring to track frame rates and performance
  void _setupPerformanceMonitoring() {
    _performanceMonitorTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      _monitorPerformance,
    );
  }
  
  /// Monitor performance metrics during animation
  void _monitorPerformance(Timer timer) {
    if (!isAnimating) return;
    
    try {
      // Check for frame drops using SchedulerBinding
      final binding = SchedulerBinding.instance;
      if (binding.hasScheduledFrame) {
        // Frame is scheduled but not rendered - potential drop
        _droppedFrameCount++;
        
        // If too many dropped frames, flag performance issues
        if (_droppedFrameCount > 10 && !_performanceIssuesDetected) {
          _performanceIssuesDetected = true;
          _handleError(
            SplashErrorType.performanceDegradation,
            'Performance degradation detected: $_droppedFrameCount dropped frames',
            null,
          );
        }
      }
      
      // Record frame timing
      final now = DateTime.now();
      if (_frameTimes.isNotEmpty) {
        final lastFrameTime = _frameTimes.last;
        final frameDuration = now.difference(DateTime.fromMillisecondsSinceEpoch(
          lastFrameTime.inMilliseconds));
        
        // Check for slow frames (> 16.67ms for 60fps)
        if (frameDuration.inMilliseconds > 20) {
          _droppedFrameCount++;
        }
      }
      
      _frameTimes.add(Duration(milliseconds: now.millisecondsSinceEpoch));
      
      // Keep only recent frame times (last 100 frames)
      if (_frameTimes.length > 100) {
        _frameTimes.removeAt(0);
      }
      
    } catch (e) {
      // Don't let performance monitoring crash the animation
      developer.log('Performance monitoring error: $e', 
                   name: 'SplashController');
    }
  }
  
  /// Preload necessary resources with error handling
  void _preloadResources() {
    try {
      // In a real implementation, this would preload actual resources
      // For now, we just mark resources as loaded successfully
      // This avoids async operations that can cause timer issues in tests
      
      // Check if resources loaded successfully
      // This is a placeholder - real implementation would check actual resources
      //const resourcesLoaded = true;
      
      
      
    } catch (e, stackTrace) {
      _resourceLoadingFailed = true;
      _handleError(
        SplashErrorType.resourceLoadingFailure,
        'Resource loading failed: $e',
        stackTrace,
      );
    }
  }
  
  /// Handle timeout scenario with enhanced error reporting
  void _handleTimeout() {
    _updateState(SplashAnimationState.timeout);
    _handleError(
      SplashErrorType.timeout,
      'Splash screen timeout after ${SplashAnimationConfig.maxSplashDuration.inSeconds} seconds',
      null,
    );
    _completeAnimationWithFallback();
  }
  
  /// Handle errors with logging and fallback navigation
  void _handleError(SplashErrorType errorType, String message, StackTrace? stackTrace) {
    _hasEncounteredError = true;
    _errorLog.add('${DateTime.now()}: $errorType - $message');
    
    // Log error for debugging
    developer.log(
      message,
      name: 'SplashController',
      error: errorType,
      stackTrace: stackTrace,
    );
    
    // Notify error callback if provided
    _onError?.call(errorType, message);
    
    // Update state based on error type
    switch (errorType) {
      case SplashErrorType.timeout:
        _updateState(SplashAnimationState.timeout);
        break;
      case SplashErrorType.resourceLoadingFailure:
        _updateState(SplashAnimationState.resourceLoadingFailed);
        break;
      default:
        _updateState(SplashAnimationState.error);
    }
  }
  
  /// Start the splash animation sequence
  void startAnimation() {
    try {
      if (_currentState == SplashAnimationState.idle && !_hasEncounteredError) {
        // Check if resources failed to load - use fallback if needed
        if (_resourceLoadingFailed) {
          _completeAnimationWithFallback();
          return;
        }
        
        _mainController.forward();
      }
    } catch (e, stackTrace) {
      _handleError(
        SplashErrorType.animationFailure,
        'Failed to start animation: $e',
        stackTrace,
      );
      _completeAnimationWithFallback();
    }
  }
  
  /// Skip to the end of animation (for testing or user interaction)
  void skipAnimation() {
    try {
      if (!_hasEncounteredError) {
        _mainController.animateTo(1.0, duration: const Duration(milliseconds: 200));
      } else {
        _completeAnimationWithFallback();
      }
    } catch (e, stackTrace) {
      _handleError(
        SplashErrorType.animationFailure,
        'Failed to skip animation: $e',
        stackTrace,
      );
      _completeAnimationWithFallback();
    }
  }
  
  /// Reset animation to initial state
  void resetAnimation() {
    try {
      _mainController.reset();
      _updateState(SplashAnimationState.idle);
      _hasEncounteredError = false;
      _resourceLoadingFailed = false;
      _performanceIssuesDetected = false;
      _droppedFrameCount = 0;
      _frameTimes.clear();
      _errorLog.clear();
      _animationStopwatch.reset();
    } catch (e, stackTrace) {
      _handleError(
        SplashErrorType.animationFailure,
        'Failed to reset animation: $e',
        stackTrace,
      );
    }
  }
  
  /// Complete the animation and trigger callback
  void _completeAnimation() {
    _cleanupTimers();
    _animationStopwatch.stop();
    
    // Fallback callback trigger if not already called during exit phase
    if (_onAnimationComplete != null) {
      _onAnimationComplete?.call();
      _onAnimationComplete = null;
    }
  }
  
  /// Complete animation with fallback navigation (for error scenarios)
  void _completeAnimationWithFallback() {
    _cleanupTimers();
    _animationStopwatch.stop();
    
    // Force callback trigger for fallback navigation
    if (_onAnimationComplete != null) {
      developer.log('Triggering fallback navigation due to error', 
                   name: 'SplashController');
      _onAnimationComplete?.call();
      _onAnimationComplete = null;
    }
  }
  
  /// Clean up all timers and resources
  void _cleanupTimers() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _performanceMonitorTimer?.cancel();
    _performanceMonitorTimer = null;
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
  
  /// Get current error log
  List<String> get errorLog => List.unmodifiable(_errorLog);
  
  /// Check if any errors have occurred
  bool get hasErrors => _hasEncounteredError;
  
  /// Check if performance issues were detected
  bool get hasPerformanceIssues => _performanceIssuesDetected;
  
  /// Get current performance metrics
  SplashPerformanceMetrics get performanceMetrics {
    final totalFrames = _frameTimes.length;
    final averageFrameTime = totalFrames > 0 
        ? _frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / totalFrames / 1000.0
        : 0.0;
    
    return SplashPerformanceMetrics(
      frameCount: totalFrames,
      averageFrameTime: averageFrameTime,
      droppedFrames: _droppedFrameCount,
      totalDuration: _animationStopwatch.elapsed,
      hadPerformanceIssues: _performanceIssuesDetected,
    );
  }
  
  /// Force immediate completion (emergency fallback)
  void forceComplete() {
    developer.log('Force completing splash screen', name: 'SplashController');
    _completeAnimationWithFallback();
  }
  
  /// Check if the controller is in a healthy state
  bool get isHealthy => !_hasEncounteredError && 
                       !_resourceLoadingFailed && 
                       !_performanceIssuesDetected;
  
  /// Get semantic label for current animation state
  String get currentStateSemanticLabel {
    return AccessibilityService.getSplashStateSemanticLabel(_currentState.name);
  }
  
  /// Update accessibility settings (for dynamic changes)
  void updateAccessibilitySettings(BuildContext context) {
    final previousReducedMotion = _reducedMotionEnabled;
    _initializeAccessibilitySettings(context);
    
    // If reduced motion setting changed, we may need to adjust animation
    if (previousReducedMotion != _reducedMotionEnabled && isAnimating) {
      developer.log(
        'Reduced motion setting changed during animation: $_reducedMotionEnabled',
        name: 'SplashController',
      );
    }
  }
  
  @override
  void dispose() {
    try {
      _cleanupTimers();
      _mainController.removeListener(_handleAnimationProgress);
      _mainController.removeStatusListener(_handleAnimationStatus);
      _mainController.dispose();
      _animationStopwatch.stop();
    } catch (e) {
      // Don't let disposal errors crash the app
      developer.log('Error during splash controller disposal: $e', 
                   name: 'SplashController');
    }
    super.dispose();
  }
}