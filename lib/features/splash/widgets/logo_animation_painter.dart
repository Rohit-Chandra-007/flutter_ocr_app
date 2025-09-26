import 'package:flutter/material.dart';
import 'logo_path.dart';

/// Custom painter for rendering the animated 'S' logo with reveal effects
/// 
/// This painter handles:
/// - Drawing the stylized 'S' logo path
/// - Progressive logo reveal based on scanner progress
/// - Glow effects and theme color integration
/// - Performance-optimized rendering
class LogoAnimationPainter extends CustomPainter {
  final double revealProgress;
  final Color logoColor;
  final Color glowColor;
  final double glowIntensity;
  final double strokeWidth;
  final bool showGlow;
  
  const LogoAnimationPainter({
    required this.revealProgress,
    required this.logoColor,
    required this.glowColor,
    this.glowIntensity = 0.3,
    this.strokeWidth = 4.0,
    this.showGlow = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (revealProgress <= 0.0) return;
    
    // Get the logo path
    final logoPath = LogoPath.getSLogoPath(size);
    
    // Create clipping path for reveal animation
    final revealPath = _createRevealPath(size);
    
    // Save canvas state for clipping
    canvas.save();
    
    // Apply reveal clipping
    canvas.clipPath(revealPath);
    
    // Draw glow effect if enabled
    if (showGlow && glowIntensity > 0) {
      _drawGlowEffect(canvas, logoPath);
    }
    
    // Draw the main logo
    _drawLogo(canvas, logoPath);
    
    // Restore canvas state
    canvas.restore();
  }
  
  /// Create a clipping path for the reveal animation
  Path _createRevealPath(Size size) {
    final bounds = LogoPath.getLogoBounds(size);
    final revealHeight = bounds.height * revealProgress;
    
    return Path()
      ..addRect(Rect.fromLTWH(
        0,
        0,
        size.width,
        bounds.top + revealHeight,
      ));
  }
  
  /// Draw the glow effect behind the logo
  void _drawGlowEffect(Canvas canvas, Path logoPath) {
    // Create multiple glow layers for better effect
    final glowLayers = [
      (width: strokeWidth * 3, opacity: glowIntensity * 0.3),
      (width: strokeWidth * 2, opacity: glowIntensity * 0.5),
      (width: strokeWidth * 1.5, opacity: glowIntensity * 0.7),
    ];
    
    for (final layer in glowLayers) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: layer.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.width * 0.5);
      
      canvas.drawPath(logoPath, glowPaint);
    }
  }
  
  /// Draw the main logo path
  void _drawLogo(Canvas canvas, Path logoPath) {
    final logoPaint = Paint()
      ..color = logoColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(logoPath, logoPaint);
  }
  
  @override
  bool shouldRepaint(LogoAnimationPainter oldDelegate) {
    return oldDelegate.revealProgress != revealProgress ||
           oldDelegate.logoColor != logoColor ||
           oldDelegate.glowColor != glowColor ||
           oldDelegate.glowIntensity != glowIntensity ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.showGlow != showGlow;
  }
  
  /// Get the logo bounds for external use
  Rect getLogoBounds(Size size) {
    return LogoPath.getLogoBounds(size);
  }
}

/// Painter specifically for the scanner line with glow effect
class ScannerLinePainter extends CustomPainter {
  final double progress;
  final Color scannerColor;
  final Color glowColor;
  final double glowIntensity;
  final double lineHeight;
  
  const ScannerLinePainter({
    required this.progress,
    required this.scannerColor,
    required this.glowColor,
    this.glowIntensity = 0.5,
    this.lineHeight = 2.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    
    final scannerY = LogoPath.getScannerYPosition(size, progress);
    final lineWidth = LogoPath.getScannerLineWidth(size);
    final startX = (size.width - lineWidth) / 2;
    final endX = startX + lineWidth;
    
    // Draw glow effect
    _drawScannerGlow(canvas, startX, endX, scannerY);
    
    // Draw main scanner line
    _drawScannerLine(canvas, startX, endX, scannerY);
  }
  
  /// Draw the glow effect for the scanner line
  void _drawScannerGlow(Canvas canvas, double startX, double endX, double y) {
    final glowLayers = [
      (height: lineHeight * 8, opacity: glowIntensity * 0.1),
      (height: lineHeight * 4, opacity: glowIntensity * 0.2),
      (height: lineHeight * 2, opacity: glowIntensity * 0.4),
    ];
    
    for (final layer in glowLayers) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: layer.opacity)
        ..strokeWidth = layer.height
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.height * 0.3);
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        glowPaint,
      );
    }
  }
  
  /// Draw the main scanner line
  void _drawScannerLine(Canvas canvas, double startX, double endX, double y) {
    final linePaint = Paint()
      ..color = scannerColor
      ..strokeWidth = lineHeight
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(startX, y),
      Offset(endX, y),
      linePaint,
    );
  }
  
  @override
  bool shouldRepaint(ScannerLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.scannerColor != scannerColor ||
           oldDelegate.glowColor != glowColor ||
           oldDelegate.glowIntensity != glowIntensity ||
           oldDelegate.lineHeight != lineHeight;
  }
}