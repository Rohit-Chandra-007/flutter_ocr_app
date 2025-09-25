import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_theme.dart';

class EmptyHistoryState extends StatelessWidget {
  const EmptyHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 60,
                color: AppTheme.primaryBlue,
              ),
            ).animate()
             .fadeIn(duration: 600.ms)
             .scale(delay: 200.ms)
             .then(delay: 1000.ms)
             .animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scaleXY(begin: 1.0, end: 1.05, duration: 2000.ms),
            
            const SizedBox(height: AppTheme.spacing32),
            
            // Title
            Text(
              'No Documents Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.headlineMedium?.color?.withValues(alpha: 0.8),
              ),
            ).animate()
             .fadeIn(delay: 400.ms, duration: 600.ms)
             .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: AppTheme.spacing12),
            
            // Subtitle
            Text(
              'Start scanning documents to build your digital library',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ).animate()
             .fadeIn(delay: 600.ms, duration: 600.ms)
             .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: AppTheme.spacing32),
            
            // Call to action
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
                vertical: AppTheme.spacing12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.accentTeal.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: AppTheme.accentTeal,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Tap the scan button to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate()
             .fadeIn(delay: 800.ms, duration: 600.ms)
             .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}