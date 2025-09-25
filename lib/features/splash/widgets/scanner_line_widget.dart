import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/splash_theme_data.dart';
import 'logo_animation_painter.dart';

/// Widget that renders an animated scanner line with soft glow effect
/// 
/// This widget coordinates scanner movement with logo reveal progress
/// and provides smooth animation curves for natural movement.
class ScannerLineWidget extends StatelessWidget {
  /// Animation controlling the scanner line position (0.0 to 1.0)
  final Animation<double> animation;
  
  /// Theme data for color coordination
  final SplashThemeData themeData;
  
  /// Intensity of the glow effect (0.0 to 1.0)
  final double glowIntensity;
  
  /// Height of the scanner line in logical pixels
  final double lineHeight;
  
  /// Whether to show the glow effect
  final bool showGlow;
  
  const ScannerLineWidget({
    super.key,
    required this.animation,
    required this.themeData,
    this.glowIntensity = 0.5,
    this.lineHeight = 2.0,
    this.showGlow = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerLinePainter(
            progress: animation.value,
            scannerColor: themeData.scannerColor,
            glowColor: themeData.glowColor,
            glowIntensity: showGlow ? glowIntensity : 0.0,
            lineHeight: lineHeight,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Enhanced scanner line widget with performance optimizations
/// 
/// This version includes additional features for better performance
/// and visual effects during the scanning animation.
class OptimizedScannerLineWidget extends StatefulWidget {
  /// Animation controlling the scanner line position (0.0 to 1.0)
  final Animation<double> animation;
  
  /// Theme data for color coordination
  final SplashThemeData themeData;
  
  /// Intensity of the glow effect (0.0 to 1.0)
  final double glowIntensity;
  
  /// Height of the scanner line in logical pixels
  final double lineHeight;
  
  /// Whether to show the glow effect
  final bool showGlow;
  
  /// Callback when scanner reaches specific positions
  final void Function(double progress)? onProgressUpdate;
  
  const OptimizedScannerLineWidget({
    super.key,
    required this.animation,
    required this.themeData,
    this.glowIntensity = 0.5,
    this.lineHeight = 2.0,
    this.showGlow = true,
    this.onProgressUpdate,
  });
  
  @override
  State<OptimizedScannerLineWidget> createState() => _OptimizedScannerLineWidgetState();
}

class _OptimizedScannerLineWidgetState extends State<OptimizedScannerLineWidget> {
  double _lastProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_handleProgressUpdate);
  }
  
  @override
  void didUpdateWidget(OptimizedScannerLineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_handleProgressUpdate);
      widget.animation.addListener(_handleProgressUpdate);
    }
  }
  
  @override
  void dispose() {
    widget.animation.removeListener(_handleProgressUpdate);
    super.dispose();
  }
  
  void _handleProgressUpdate() {
    final currentProgress = widget.animation.value;
    
    // Only trigger callback if progress changed significantly (optimization)
    if ((currentProgress - _lastProgress).abs() > 0.01) {
      _lastProgress = currentProgress;
      widget.onProgressUpdate?.call(currentProgress);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ScannerLinePainter(
              progress: widget.animation.value,
              scannerColor: widget.themeData.scannerColor,
              glowColor: widget.themeData.glowColor,
              glowIntensity: widget.showGlow ? widget.glowIntensity : 0.0,
              lineHeight: widget.lineHeight,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// Utility class for scanner line animation calculations
class ScannerLineAnimationUtils {
  /// Calculate the optimal glow intensity based on animation progress
  /// 
  /// This creates a more dynamic glow effect that varies during animation.
  static double calculateDynamicGlowIntensity(double progress, double baseIntensity) {
    // Increase glow intensity at the beginning and end of animation
    const peakStart = 0.1;
    const peakEnd = 0.9;
    
    if (progress <= peakStart) {
      // Fade in glow at start
      return baseIntensity * (progress / peakStart);
    } else if (progress >= peakEnd) {
      // Fade out glow at end
      return baseIntensity * ((1.0 - progress) / (1.0 - peakEnd));
    } else {
      // Maintain steady glow in middle
      return baseIntensity;
    }
  }
  
  /// Calculate scanner line width based on progress for dynamic sizing
  static double calculateDynamicLineWidth(double progress, double baseWidth, Size containerSize) {
    // Slightly vary line width during animation for more dynamic effect
    const variation = 0.2; // 20% variation
    final sineWave = math.sin(progress * 4 * math.pi) * variation;
    return baseWidth * (1.0 + sineWave);
  }
  
  /// Get the scanner line color with dynamic opacity
  static Color getScannerColorWithDynamicOpacity(Color baseColor, double progress) {
    // Vary opacity slightly during animation
    const minOpacity = 0.8;
    const maxOpacity = 1.0;
    final opacity = minOpacity + (maxOpacity - minOpacity) * (0.5 + 0.5 * math.sin(progress * 2 * math.pi));
    
    return baseColor.withValues(alpha: opacity);
  }
}