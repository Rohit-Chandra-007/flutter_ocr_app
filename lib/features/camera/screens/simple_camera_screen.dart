import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../../../features/ocr/services/ocr_service.dart';
import '../../../features/ocr/services/pdf_service.dart';
import '../../scan_history/providers/scan_history_provider.dart';

class SimpleCameraScreen extends ConsumerStatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  ConsumerState<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends ConsumerState<SimpleCameraScreen> {
  bool _isProcessing = false;
  double _processingProgress = 0.0;

  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      setState(() => _isProcessing = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        await _processImageFile(image.path, [image.path]);
      }
    } catch (e) {
      // Close processing dialog if open
      if (mounted && _isProcessing) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickAndProcessPDF() async {
    try {
      setState(() => _isProcessing = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Show processing dialog with progress
        _showProcessingDialog(showProgress: true);

        // Extract text from PDF with progress callback
        final extractedText = await PDFService.extractTextFromPDF(
          file,
          (progress) {
            setState(() => _processingProgress = progress);
          },
        );
        
        // Create document title from filename or first few words
        String title = result.files.single.name.replaceAll('.pdf', '');
        if (extractedText.isNotEmpty) {
          final words = extractedText.split(' ').take(4).join(' ');
          if (words.isNotEmpty && words.length < title.length) {
            title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
          }
        }

        // Create scan document (PDF processing creates temporary image files)
        final document = ScanDocument.create(
          title: title,
          extractedText: extractedText,
          imagePaths: [file.path], // Store PDF path for now
        );

        // Save to database
        await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

        // Close processing dialog
        if (mounted) Navigator.of(context).pop();

        // Show success and navigate back
        _showSuccess('PDF processed successfully!');
        
        // Navigate back to home after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      // Close processing dialog if open
      if (mounted && _isProcessing) Navigator.of(context).pop();
      _showError('Failed to process PDF: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImageFile(String imagePath, List<String> imagePaths) async {
    try {
      // Show processing dialog
      _showProcessingDialog();

      // Extract text using OCR
      final extractedText = await OCRService.extractTextFromImage(imagePath);
      
      // Create document title from first few words or use default
      String title = 'Scanned Document';
      if (extractedText.isNotEmpty) {
        final words = extractedText.split(' ').take(4).join(' ');
        if (words.isNotEmpty) {
          title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
        }
      }

      // Create scan document
      final document = ScanDocument.create(
        title: title,
        extractedText: extractedText,
        imagePaths: imagePaths,
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
    } catch (e) {
      // Close processing dialog if open
      if (mounted) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    }
  }

  void _showProcessingDialog({bool showProgress = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showProgress) ...[
              CircularProgressIndicator(
                value: _processingProgress > 0 ? _processingProgress : null,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'Processing PDF... ${(_processingProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Processing image...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
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
              
              const SizedBox(height: 16),
              
              // PDF button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _pickAndProcessPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Import PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentOrange,
                    side: const BorderSide(color: AppTheme.accentOrange),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'The app will automatically extract text from your images or PDF files using advanced OCR technology.',
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