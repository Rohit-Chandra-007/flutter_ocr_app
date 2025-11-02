import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:scanflow/core/constants/app_enum.dart';
import 'package:scanflow/core/extensions/scan_source_extension.dart';
import 'package:scanflow/core/utils/navigation_utils.dart';
import 'package:scanflow/core/utils/snackbar_utils.dart';
import 'package:scanflow/features/document_scanner/views/screens/camera_scanner_screen.dart';

import '../../../../core/theme/app_theme.dart';

import '../../viewmodels/document_processor_provider.dart';
import 'scan_option_card.dart';
import '../../../../core/widgets/scan_processing_dialog.dart';

class ScanOptionsGrid extends ConsumerStatefulWidget {
  const ScanOptionsGrid({
    super.key,
  });

  @override
  ConsumerState<ScanOptionsGrid> createState() => _ScanOptionsGridState();
}

class _ScanOptionsGridState extends ConsumerState<ScanOptionsGrid> {
  final Logger _logger = Logger();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _logger.i('ScanOptions: Initializing scan options grid');
  }

  Future<void> _handleScanOption(ScanSource source) async {
    _logger.i('ScanOptions: Scan option selected: ${source.name}');

    if (_isProcessing) {
      _logger.w('ScanOptions: Already processing, ignoring request');
      return;
    }

    if (source == ScanSource.camera) {
      _logger.i('ScanOptions: Navigating to camera screen');
      NavigationUtils.navigateWithFadeSlide(
        context,
        const CameraScannerScreen(),
      );

      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Show processing dialog
      _logger.d('ScanOptions: Showing processing dialog');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ScanProcessingDialog(),
        );
      }

      bool success = false;

      _logger.d('ScanOptions: Processing source: ${source.name}');
      switch (source) {
        case ScanSource.gallery:
          _logger.d('ScanOptions: Starting gallery image processing');
          success = await ref
              .read(documentProcessorProvider.notifier)
              .processImageFromGallery();
          break;
        case ScanSource.pdf:
          _logger.d('ScanOptions: Starting PDF processing');
          success =
              await ref.read(documentProcessorProvider.notifier).processPDF();
          break;
        case ScanSource.multipleImages:
          _logger.d('ScanOptions: Starting multiple images processing');
          success = await ref
              .read(documentProcessorProvider.notifier)
              .processMultipleImages();
          break;
        case ScanSource.camera:
          break;
      }

      _logger.i('ScanOptions: Processing completed. Success: $success');

      // Close processing dialog
      if (mounted) {
        _logger.d('ScanOptions: Closing processing dialog');
        Navigator.of(context).pop();

        if (success) {
          _logger.i('ScanOptions: Showing success message');
          SnackbarUtils.showSuccess(
              context, 'Document processed successfully!');
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) Navigator.of(context).pop();
        }
      }
    } catch (e, stackTrace) {
      _logger.e('ScanOptions: Error processing scan option',
          error: e, stackTrace: stackTrace);
      // Close processing dialog
      if (mounted) {
        Navigator.of(context).pop();
        // Extract clean error message
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        SnackbarUtils.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        ScanOptionCard(
          icon: Icons.camera_alt,
          title: ScanSource.camera.label,
          subtitle: ScanSource.camera.subtitle,
          color: AppTheme.primaryBlue,
          onTap:
              _isProcessing ? null : () => _handleScanOption(ScanSource.camera),
          delay: 0,
        ),
        ScanOptionCard(
          icon: Icons.photo_library,
          title: ScanSource.gallery.label,
          subtitle: ScanSource.gallery.subtitle,
          color: AppTheme.accentTeal,
          onTap: _isProcessing
              ? null
              : () => _handleScanOption(ScanSource.gallery),
          delay: 100,
        ),
        ScanOptionCard(
          icon: Icons.picture_as_pdf,
          title: ScanSource.pdf.label,
          subtitle: ScanSource.pdf.subtitle,
          color: AppTheme.accentOrange,
          onTap: _isProcessing ? null : () => _handleScanOption(ScanSource.pdf),
          delay: 200,
        ),
        ScanOptionCard(
          icon: Icons.photo_library_outlined,
          title: ScanSource.multipleImages.label,
          subtitle: ScanSource.multipleImages.subtitle,
          color: Colors.purple,
          onTap: _isProcessing
              ? null
              : () => _handleScanOption(ScanSource.multipleImages),
          delay: 300,
        ),
      ],
    );
  }
}
