import 'package:flutter/material.dart';

class FilePickerMenu extends StatelessWidget {
  final Function() onImagePick;
  final Function() onPdfPick;

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionButton(
            icon: Icons.image,
            label: 'Pick Image',
            onTap: onImagePick,
          ),
          const SizedBox(height: 15),
          _buildOptionButton(
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
    required IconData icon,
    required String label,
    required Function() onTap,
    Color color = Colors.blue,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
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