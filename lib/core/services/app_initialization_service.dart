import 'package:flutter/foundation.dart';
import 'database_service.dart';

/// Service responsible for initializing app resources during splash screen
class AppInitializationService {
  static bool _isInitialized = false;
  static String? _initializationError;
  
  /// Check if app initialization is complete
  static bool get isInitialized => _isInitialized;
  
  /// Get initialization error if any occurred
  static String? get initializationError => _initializationError;
  
  /// Initialize all app resources
  /// Returns true if successful, false if failed
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Reset error state
      _initializationError = null;
      
      // Initialize database
      await DatabaseService.initialize();
      
      // Add any other initialization tasks here
      // For example: SharedPreferences, Firebase, etc.
      
      _isInitialized = true;
      return true;
      
    } catch (error, stackTrace) {
      _initializationError = 'Failed to initialize app: ${error.toString()}';
      
      // Log error in debug mode
      if (kDebugMode) {
        print('App initialization failed: $error');
        print('Stack trace: $stackTrace');
      }
      
      return false;
    }
  }
  
  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
    _initializationError = null;
  }
  
  /// Get a user-friendly error message
  static String getUserFriendlyError() {
    if (_initializationError == null) return 'Unknown error occurred';
    
    // Convert technical errors to user-friendly messages
    if (_initializationError!.contains('database') || 
        _initializationError!.contains('Isar')) {
      return 'Failed to initialize app storage. Please restart the app.';
    }
    
    return 'App initialization failed. Please restart the app.';
  }
}