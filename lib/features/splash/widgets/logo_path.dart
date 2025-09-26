import 'package:flutter/material.dart';

/// Utility class for generating the stylized 'S' logo path and scanner line path
class LogoPath {
  /// Generate a stylized 'S' logo path optimized for scanner line animation
  /// 
  /// The path is designed to be elegant and modern, with smooth curves
  /// that work well with the scanner line reveal animation.
  static Path getSLogoPath(Size size) {
    final path = Path();
    
    // Calculate dimensions based on size
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final logoWidth = size.width * 0.3; // 30% of container width
    final logoHeight = size.height * 0.4; // 40% of container height
    
    // Define key points for the 'S' shape
    final left = centerX - logoWidth / 2;
    final right = centerX + logoWidth / 2;
    final top = centerY - logoHeight / 2;
    final bottom = centerY + logoHeight / 2;
    final middle = centerY;
    
    // Control point offsets for smooth curves
    final curveOffset = logoWidth * 0.3;
    
    // Start from top-right, moving counter-clockwise to create 'S'
    path.moveTo(right, top + logoHeight * 0.2);
    
    // Top curve (right to left)
    path.cubicTo(
      right, top,                           // Control point 1
      left + curveOffset, top,              // Control point 2  
      left, top + logoHeight * 0.2,        // End point
    );
    
    // Left side of top curve
    path.cubicTo(
      left, top + logoHeight * 0.35,       // Control point 1
      left + curveOffset * 0.5, middle - logoHeight * 0.1, // Control point 2
      centerX, middle,                      // End point (center)
    );
    
    // Middle transition to bottom curve
    path.cubicTo(
      centerX + curveOffset * 0.5, middle + logoHeight * 0.1, // Control point 1
      right, bottom - logoHeight * 0.35,   // Control point 2
      right, bottom - logoHeight * 0.2,    // End point
    );
    
    // Bottom curve (right to left)
    path.cubicTo(
      right, bottom,                        // Control point 1
      left + curveOffset, bottom,           // Control point 2
      left, bottom - logoHeight * 0.2,     // End point
    );
    
    return path;
  }
  
  /// Generate scanner line path that follows the logo outline
  /// 
  /// This creates a path that the scanner line will follow to reveal
  /// the logo progressively from top to bottom.
  static List<Offset> getScannerPath(Size size) {
    final path = getSLogoPath(size);
    final pathMetrics = path.computeMetrics();
    final scannerPoints = <Offset>[];
    
    // Extract points along the path for scanner line movement
    for (final metric in pathMetrics) {
      final pathLength = metric.length;
      final numPoints = (pathLength / 5).round().clamp(20, 100); // Adaptive point density
      
      for (int i = 0; i <= numPoints; i++) {
        final distance = (i / numPoints) * pathLength;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          scannerPoints.add(tangent.position);
        }
      }
    }
    
    // Sort points by Y coordinate for top-to-bottom scanning
    scannerPoints.sort((a, b) => a.dy.compareTo(b.dy));
    
    return scannerPoints;
  }
  
  /// Get the bounding box of the logo path
  static Rect getLogoBounds(Size size) {
    final path = getSLogoPath(size);
    return path.getBounds();
  }
  
  /// Calculate the scanner line position based on animation progress
  /// 
  /// Returns the Y coordinate where the scanner line should be positioned
  /// for the given progress (0.0 to 1.0).
  static double getScannerYPosition(Size size, double progress) {
    final bounds = getLogoBounds(size);
    final scannerRange = bounds.height * 1.2; // Extend slightly beyond logo
    final startY = bounds.top - scannerRange * 0.1;
    
    return startY + (scannerRange * progress);
  }
  
  /// Get the width of the scanner line based on logo dimensions
  static double getScannerLineWidth(Size size) {
    return size.width * 0.8; // 80% of container width
  }
  
  /// Calculate logo reveal progress based on scanner position
  /// 
  /// Returns how much of the logo should be revealed (0.0 to 1.0)
  /// based on the current scanner line position.
  static double getLogoRevealProgress(Size size, double scannerProgress) {
    // Logo starts revealing when scanner is 20% through its journey
    // and is fully revealed when scanner is 80% through
    const revealStart = 0.2;
    const revealEnd = 0.8;
    
    if (scannerProgress <= revealStart) return 0.0;
    if (scannerProgress >= revealEnd) return 1.0;
    
    return (scannerProgress - revealStart) / (revealEnd - revealStart);
  }
}