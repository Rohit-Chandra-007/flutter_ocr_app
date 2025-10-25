class AppConstants {
  AppConstants._();
  // App-wide constants
  static const String appName = 'OCR Scanner';
  static const String appVersion = '1.0.0';
  static const String kAppName = 'ScanFlow';
  static const String kAppVersion = '1.0.0';
  static const String kAppDescription =
      'A beautiful, modern OCR mobile application with seamless user experience.';
  static const String kAppTagline =
      'Transform your device into a powerful document scanner with intelligent text recognition.';

  // Animation durations
  static const Duration scanningAnimationDuration = Duration(seconds: 2);

  // File paths
  static const String scanningAnimationPath = 'assets/scanning_animation.json';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 15.0;

  // PDF Processing
  static const int pdfRenderWidth = 2000;
  static const int pdfRenderHeight = 3000;

  // OCR Processing Limits
  static const int maxPagesPerDocument = 25;

  // Messages
  static const String noDocumentSelectedTitle = 'No Document Selected';
  static const String noDocumentSelectedSubtitle =
      'Tap the + button to start scanning';
  static const String textCopiedMessage = 'Text copied to clipboard';
  static const String pageLimitExceededTitle = 'Too Many Pages';
  static const String pageLimitExceededMessage =
      'Maximum 25 pages per document for optimal performance.\n\n'
      'Please split your document into smaller parts or select fewer pages.';

  /// Common animation durations used across the app so screens stay in sync.
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration regular = Duration(milliseconds: 300);
  static const Duration relaxed = Duration(milliseconds: 600);

  /// Length of the splash intro animation.
  static const Duration splashIntro = Duration(milliseconds: 1000);

  /// Total splash hold before navigation to keep sequencing consistent.
  static const Duration splashSequence = Duration(milliseconds: 2000);
}
