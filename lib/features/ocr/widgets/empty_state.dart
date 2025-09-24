import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description, 
            size: 100, 
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            AppConstants.noDocumentSelectedTitle,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppConstants.noDocumentSelectedSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}