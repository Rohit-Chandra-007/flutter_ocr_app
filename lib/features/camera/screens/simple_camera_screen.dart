import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../../../features/ocr/services/ocr_service.dart';
import '../../scan_history/providers/scan_history_provider.dart';

class SimpleCameraScreen extends ConsumerStatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  ConsumerState<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends ConsumerState<SimpleCameraScreen> {
  bool _isProcessing = false;

  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      setState(() => _isProcessing = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        // Show processing dialog
        _showProcessingDialog();

        // Extract text using OCR
        final extractedText = await OCRService.extractTextFromImage(image.path);
        
        // Create document title from first few words or use default
        String title = 'Scanned Document';
        if (extractedText.isNotEmpty) {
          final words = extractedText.split(' ').take(4).join(' ');
          if (words.isNotEmpty) {
            title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
          }
        }

        // Create scan document
        final document = ScanDocument(
          title: title,
          extractedText: extractedText,
          imagePaths: [image.path],
        );

        // Save to database
        await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

        // Close processing dialog
        if (mounted) Navigator.of(context).pop();

        // Show success and navigate back
        _showSuccess('Document scanned successfully!');
        
        // Navigate back to home after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      // Close processing dialog if open
      if (mounted && _isProcessing) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processing image...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.document_scanner,
                size: 120,
                color: AppTheme.primaryBlue.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Choose how to scan your document',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Camera button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing 
                      ? null 
                      : () => _pickAndProcessImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Gallery button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing 
                      ? null 
                      : () => _pickAndProcessImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'The app will automatically extract text from your image using OCR technology.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}