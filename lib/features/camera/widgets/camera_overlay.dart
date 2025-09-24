import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CameraOverlayPainter(),
      ),
    );
  }
}

class _CameraOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for potential future use
    // final paint = Paint()
    //   ..color = AppTheme.primaryBlue.withValues(alpha: 0.8)
    //   ..strokeWidth = 2.0
    //   ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final rectWidth = size.width * 0.8;
    final rectHeight = size.height * 0.6;
    
    final rect = Rect.fromCenter(
      center: center,
      width: rectWidth,
      height: rectHeight,
    );

    // Draw corner brackets
    const cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppTheme.accentTeal
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );

    // Draw grid lines for better composition
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    // Vertical grid lines
    final verticalSpacing = rectWidth / 3;
    for (int i = 1; i < 3; i++) {
      final x = rect.left + (verticalSpacing * i);
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines
    final horizontalSpacing = rectHeight / 3;
    for (int i = 1; i < 3; i++) {
      final y = rect.top + (horizontalSpacing * i);
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}