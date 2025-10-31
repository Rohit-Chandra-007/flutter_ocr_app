import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _isProcessing = false;

  Future<void> _handleScanOption(ScanSource source) async {
    if (_isProcessing) return;

    if (source == ScanSource.camera) {
      NavigationUtils.navigateWithFadeSlide(
        context,
        const CameraScannerScreen(),
      );

      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Show processing dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ScanProcessingDialog(),
        );
      }

      bool success = false;

      switch (source) {
        case ScanSource.gallery:
          success = await ref
              .read(documentProcessorProvider.notifier)
              .processImageFromGallery();
          break;
        case ScanSource.pdf:
          success =
              await ref.read(documentProcessorProvider.notifier).processPDF();
          break;
        case ScanSource.multipleImages:
          success = await ref
              .read(documentProcessorProvider.notifier)
              .processMultipleImages();
          break;
        case ScanSource.camera:
          break;
      }

      // Close processing dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        SnackbarUtils.showSuccess(context, 'Document processed successfully!');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      // Close processing dialog
      if (mounted) Navigator.of(context).pop();
      SnackbarUtils.showError(context, e.toString());
    } finally {
      setState(() => _isProcessing = false);
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
