import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCapturing;
  final AnimationController animationController;

  const CaptureButton({
    super.key,
    required this.onPressed,
    required this.isCapturing,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onPressed,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final scale = 1.0 - (animationController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isCapturing 
                      ? AppTheme.accentOrange 
                      : AppTheme.primaryBlue,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isCapturing
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentOrange,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: AppTheme.primaryBlue,
                      size: 32,
                    ),
            ),
          );
        },
      ),
    );
  }
}