import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../viewmodels/camera_scanner_provider.dart';
import '../../viewmodels/document_processor_provider.dart';
import '../widgets/camera_preview_view.dart';
import '../../../../core/widgets/error_widget.dart';
import '../widgets/camera_loading_view.dart';
import '../widgets/camera_permission_view.dart';
import '../../../../core/widgets/scan_processing_dialog.dart';

class CameraScannerScreen extends ConsumerStatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  ConsumerState<CameraScannerScreen> createState() =>
      _CameraScannerScreenState();
}

class _CameraScannerScreenState extends ConsumerState<CameraScannerScreen> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.i('CameraScreen: Initializing camera scanner');
    Future.microtask(() {
      ref.read(cameraScannerProvider.notifier).initialize();
    });
  }

  Future<void> _handleCapture() async {
    try {
      _logger.i('CameraScreen: Capture button pressed');
      final notifier = ref.read(cameraScannerProvider.notifier);

      _logger.d('CameraScreen: Capturing photo');
      final imagePath = await notifier.capturePhoto();
      _logger.i('CameraScreen: Photo captured: $imagePath');

      if (imagePath == null || imagePath.isEmpty) {
        _logger.e('CameraScreen: Failed to capture photo - null or empty path');
        _showError('Failed to capture photo');
        return;
      }

      // Show processing dialog
      _logger.d('CameraScreen: Showing processing dialog');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ScanProcessingDialog(),
        );
      }

      _logger.d('CameraScreen: Starting document processing');
      final success = await ref
          .read(documentProcessorProvider.notifier)
          .processImageFromCamera(imagePath);
      _logger.i('CameraScreen: Document processing result: $success');

      // Close processing dialog
      if (mounted) {
        _logger.d('CameraScreen: Closing processing dialog');
        Navigator.of(context).pop();
      }

      if (success) {
        _logger.i('CameraScreen: Document scanned successfully');
        _showSuccess('Document scanned successfully!');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      } else {
        _logger.w('CameraScreen: Document processing failed');
        _showError('Failed to process document');
      }
    } catch (e, stackTrace) {
      _logger.e('CameraScreen: Error in _handleCapture',
          error: e, stackTrace: stackTrace);
      // Close processing dialog
      if (mounted) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    }
  }

  Future<void> _handleGalleryPick() async {
    try {
      // Show processing dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ScanProcessingDialog(),
        );
      }

      final success = await ref
          .read(documentProcessorProvider.notifier)
          .processImageFromGallery();

      // Close processing dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        _showSuccess('Document scanned successfully!');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      // Close processing dialog
      if (mounted) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    }
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
    final scannerState = ref.watch(cameraScannerProvider);
    final notifier = ref.read(cameraScannerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Document',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (scannerState.isReady)
            IconButton(
              icon: Icon(_getFlashIcon(scannerState.flashMode),
                  color: Colors.white),
              onPressed: () => notifier.toggleFlash(),
            ),
        ],
      ),
      body: _buildBody(scannerState, notifier),
    );
  }

  Widget _buildBody(scannerState, notifier) {
    if (scannerState.hasError) {
      return ErrorWidgetView(
        errorMessage: scannerState.errorMessage ?? 'Unknown error',
        onRetry: () => notifier.initialize(),
      );
    }

    if (scannerState.isLoading) {
      return const CameraLoadingView();
    }

    if (scannerState.needsPermission) {
      return CameraPermissionView(
        onRequestPermission: () => notifier.requestPermission(),
      );
    }

    if (scannerState.isReady && notifier.controller != null) {
      return CameraPreviewView(
        controller: notifier.controller!,
        isCapturing: scannerState.isCapturing,
        canSwitchCamera: scannerState.cameras.length > 1,
        onCapture: _handleCapture,
        onGalleryPick: _handleGalleryPick,
        onSwitchCamera: () => notifier.switchCamera(),
      );
    }

    return const CameraLoadingView();
  }

  IconData _getFlashIcon(flashMode) {
    return switch (flashMode) {
      FlashMode.off => Icons.flash_off,
      FlashMode.auto => Icons.flash_auto,
      FlashMode.always => Icons.flash_on,
      FlashMode.torch => Icons.flashlight_on,
      _ => Icons.flash_off,
    };
  }
}
