import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

import 'camera_capture_button.dart';

class CameraPreviewView extends StatelessWidget {
  final CameraController controller;
  final bool isCapturing;
  final bool canSwitchCamera;
  final VoidCallback onCapture;
  final VoidCallback onGalleryPick;
  final VoidCallback onSwitchCamera;

  const CameraPreviewView({
    super.key,
    required this.controller,
    required this.isCapturing,
    required this.canSwitchCamera,
    required this.onCapture,
    required this.onGalleryPick,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(controller),
        ),

        // Camera overlay with guidelines
       // const CameraOverlay(),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                IconButton(
                  onPressed: isCapturing ? null : onGalleryPick,
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 32,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),

                // Capture button
                CameraCaptureButton(
                  onPressed: onCapture,
                  isCapturing: isCapturing,
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(delay: 300.ms),

                // Switch camera button
                IconButton(
                  onPressed: canSwitchCamera && !isCapturing
                      ? onSwitchCamera
                      : null,
                  icon: Icon(
                    Icons.flip_camera_ios,
                    color: canSwitchCamera ? Colors.white : Colors.grey,
                    size: 32,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
