import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_constants.dart';

class ProgressOverlay extends StatelessWidget {
  final double progress;
  final AnimationController animationController;

  const ProgressOverlay({
    super.key,
    required this.progress,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              AppConstants.scanningAnimationPath,
              controller: animationController,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Processing ${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}