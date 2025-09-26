import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../../../features/ocr/services/ocr_service.dart';
import '../../../features/ocr/services/pdf_service.dart';
import '../../scan_history/providers/scan_history_provider.dart';

class ScanOptionsScreen extends ConsumerStatefulWidget {
  const ScanOptionsScreen({super.key});

  @override
  ConsumerState<ScanOptionsScreen> createState() => _ScanOptionsScreenState();
}

class _ScanOptionsScreenState extends ConsumerState<ScanOptionsScreen> {
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
      _showError('Failed to process image: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickAndProcessMultipleImages() async {
    try {
      setState(() => _isProcessing = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.where((file) => file.path != null).toList();

        if (files.isEmpty) {
          _showError('No valid images selected');
          return;
        }

        // Show processing dialog with progress
        _showProcessingDialog(
            showProgress: true,
            customMessage: 'Processing ${files.length} images...');

        // Process each image with OCR during upload
        final imagePaths = files.map((file) => file.path!).toList();
        final pages = await OCRService.processMultipleImages(
          imagePaths,
          (progress) {
            setState(() => _processingProgress = progress);
          },
        );

        // Create document title based on number of pages
        String title = 'Multi-page Document (${files.length} pages)';

        // Create scan document using new structure
        final document = ScanDocument.createFromPages(
          title: title,
          pages: pages,
        );

        // Save to database
        await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

        // Close processing dialog
        if (mounted) Navigator.of(context).pop();

        // Show success and navigate back
        _showSuccess('${files.length} images processed successfully!');

        // Navigate back to home after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted && _isProcessing) Navigator.of(context).pop();
      _showError('Failed to process images: ${e.toString()}');
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
        _showProcessingDialog(
            showProgress: true, customMessage: 'Processing PDF...');

        // Extract individual pages from PDF with progress callback
        final pages = await PDFService.extractPagesFromPDF(
          file,
          (progress) {
            setState(() => _processingProgress = progress);
          },
        );

        // Create document title from filename
        String title = result.files.single.name.replaceAll('.pdf', '');

        // Create scan document using new structure
        final document = ScanDocument.createFromPages(
          title: title,
          pages: pages,
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
      if (mounted && _isProcessing) Navigator.of(context).pop();
      _showError('Failed to process PDF: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImageFile(
      String imagePath, List<String> imagePaths) async {
    try {
      _showProcessingDialog();

      // Process single image with OCR during upload
      final pages = await OCRService.processMultipleImages([imagePath], null);

      String title = 'Scanned Document';
      if (pages.isNotEmpty && pages.first.extractedText.isNotEmpty) {
        final words = pages.first.extractedText.split(' ').take(4).join(' ');
        if (words.isNotEmpty) {
          title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
        }
      }

      final document = ScanDocument.createFromPages(
        title: title,
        pages: pages,
      );

      await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

      if (mounted) Navigator.of(context).pop();
      _showSuccess('Document scanned successfully!');

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    }
  }

  void _showProcessingDialog(
      {bool showProgress = false, String? customMessage}) {
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
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                customMessage ??
                    'Processing... ${(_processingProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                customMessage ?? 'Processing image...',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Text(
                'Choose Scan Method',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to scan your document',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Scan options grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  // Camera option
                  _buildScanOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    color: AppTheme.primaryBlue,
                    onTap: _isProcessing
                        ? null
                        : () => _pickAndProcessImage(ImageSource.camera),
                    delay: 0,
                  ),

                  // Gallery option
                  _buildScanOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: 'Choose image',
                    color: AppTheme.accentTeal,
                    onTap: _isProcessing
                        ? null
                        : () => _pickAndProcessImage(ImageSource.gallery),
                    delay: 100,
                  ),

                  // PDF option
                  _buildScanOption(
                    icon: Icons.picture_as_pdf,
                    title: 'PDF File',
                    subtitle: 'Import PDF',
                    color: AppTheme.accentOrange,
                    onTap: _isProcessing ? null : _pickAndProcessPDF,
                    delay: 200,
                  ),

                  // Multiple images option - NOW IMPLEMENTED!
                  _buildScanOption(
                    icon: Icons.photo_library_outlined,
                    title: 'Images',
                    subtitle: 'Batch scan',
                    color: Colors.purple,
                    onTap: _isProcessing ? null : _pickAndProcessMultipleImages,
                    delay: 300,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Footer info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Advanced OCR technology automatically extracts text from your documents',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryBlue,
                            ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (onTap != null ? color : Colors.grey)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: onTap != null ? color : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: onTap != null ? null : Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                onTap != null ? Colors.grey[600] : Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
