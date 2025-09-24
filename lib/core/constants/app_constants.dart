class AppConstants {
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
  
  // Messages
  static const String noDocumentSelectedTitle = 'No Document Selected';
  static const String noDocumentSelectedSubtitle = 'Tap the + button to start scanning';
  static const String textCopiedMessage = 'Text copied to clipboard';
}