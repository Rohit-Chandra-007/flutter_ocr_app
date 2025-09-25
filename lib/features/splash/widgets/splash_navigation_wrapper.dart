import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../../scan_history/screens/home_screen.dart';
import '../../../core/services/app_initialization_service.dart';

/// Navigation wrapper that handles the seamless transition from splash screen to home screen
class SplashNavigationWrapper extends StatefulWidget {
  const SplashNavigationWrapper({super.key});

  @override
  State<SplashNavigationWrapper> createState() => _SplashNavigationWrapperState();
}

class _SplashNavigationWrapperState extends State<SplashNavigationWrapper>
    with TickerProviderStateMixin {
  bool _showSplash = true;
  bool _isTransitioning = false;
  bool _initializationStarted = false;
  bool _initializationComplete = false;
  String? _initializationError;
  
  late AnimationController _transitionController;
  late Animation<double> _homeScreenFadeAnimation;
  late Animation<double> _homeScreenSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create transition controller for smooth navigation
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Create fade animation for home screen entrance
    _homeScreenFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    // Create subtle slide animation for home screen entrance
    _homeScreenSlideAnimation = Tween<double>(
      begin: 0.02,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    
    // Start app initialization
    _startAppInitialization();
  }
  
  /// Start app initialization in the background during splash
  void _startAppInitialization() {
    if (_initializationStarted) return;
    
    _initializationStarted = true;
    
    AppInitializationService.initialize().then((success) {
      if (mounted) {
        setState(() {
          _initializationComplete = true;
          if (!success) {
            _initializationError = AppInitializationService.getUserFriendlyError();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  /// Handle the completion of splash animation and trigger seamless navigation
  void _onSplashAnimationComplete() {
    if (!mounted || _isTransitioning) return;
    
    // Check if initialization is complete before proceeding
    if (!_initializationComplete) {
      // If initialization is still in progress, wait a bit more
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _onSplashAnimationComplete();
      });
      return;
    }
    
    // Check for initialization errors
    if (_initializationError != null) {
      _showInitializationError();
      return;
    }
    
    setState(() {
      _isTransitioning = true;
    });

    // Use WidgetsBinding to ensure proper frame timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Start the transition to home screen
      _startSeamlessTransition();
    });
  }
  
  /// Show initialization error dialog
  void _showInitializationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Text(_initializationError ?? 'Unknown error occurred'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  /// Retry app initialization
  void _retryInitialization() {
    setState(() {
      _initializationStarted = false;
      _initializationComplete = false;
      _initializationError = null;
    });
    
    // Reset initialization service
    AppInitializationService.reset();
    
    // Start initialization again
    _startAppInitialization();
  }

  /// Start the seamless transition from splash to home screen
  void _startSeamlessTransition() {
    if (!mounted) return;
    
    // Switch to home screen immediately to avoid flash
    setState(() {
      _showSplash = false;
    });
    
    // Start the home screen entrance animation
    _transitionController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show error screen if initialization failed and user dismissed dialog
    if (_initializationError != null && !_showSplash) {
      return _buildErrorScreen();
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onAnimationComplete: _onSplashAnimationComplete,
            )
          : _buildHomeScreenWithTransition(),
    );
  }
  
  /// Build error screen for initialization failures
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'App Initialization Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _initializationError ?? 'Unknown error occurred',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _retryInitialization,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build home screen with seamless entrance animation
  Widget _buildHomeScreenWithTransition() {
    return AnimatedBuilder(
      key: const ValueKey('home'),
      animation: _transitionController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _homeScreenSlideAnimation.value),
          child: Opacity(
            opacity: _homeScreenFadeAnimation.value,
            child: const HomeScreen(),
          ),
        );
      },
    );
  }
}