import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

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
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  ),
                  Icon(
                    Icons.document_scanner,
                    size: 60,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                  ),
                ],
              ),
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