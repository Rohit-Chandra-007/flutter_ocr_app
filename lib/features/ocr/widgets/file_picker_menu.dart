import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class FilePickerMenu extends StatelessWidget {
  final VoidCallback onImagePick;
  final VoidCallback onPdfPick;

  const FilePickerMenu({
    super.key,
    required this.onImagePick,
    required this.onPdfPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionButton(
            context: context,
            icon: Icons.image,
            label: 'Pick Image',
            onTap: onImagePick,
          ),
          const SizedBox(height: 15),
          _buildOptionButton(
            context: context,
            icon: Icons.picture_as_pdf,
            label: 'Pick PDF',
            onTap: onPdfPick,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}