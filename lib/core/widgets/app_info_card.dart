import 'package:flutter/material.dart';
import 'package:scanflow/core/constants/app_constants.dart';
import 'package:scanflow/core/theme/app_theme.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.accentTeal,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/icons/scanflow_logo.png',
              fit: BoxFit.cover,
              semanticLabel: 'app icon',
              width: 64,
              height: 64,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.kAppName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.kAppDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }
}
