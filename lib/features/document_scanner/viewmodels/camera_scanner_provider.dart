import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scanflow/core/constants/app_enum.dart';

import '../models/scanner_state.dart';

part 'camera_scanner_provider.g.dart';

// Camera coordination state (outside notifier class)
List<CameraDescription>? _cachedCameras;
Future<List<CameraDescription>>? _camerasFuture;
bool _isInitializing = false;
bool _hasScheduledWarmUp = false;

@riverpod
class CameraScanner extends _$CameraScanner {
  @override
  ScannerState build() {
    final keepAliveLink = ref.keepAlive();
    ref.onDispose(() {
      state.controller?.dispose();
      keepAliveLink.close();
    });
    _scheduleWarmUp();
    return const ScannerState();
  }

  void _scheduleWarmUp() {
    if (_hasScheduledWarmUp) return;
    _hasScheduledWarmUp = true;
    Future.microtask(warmUp);
  }

  Future<void> warmUp() async {
    if (state.controller?.value.isInitialized == true && state.isReady) return;
    await initialize();
  }

  Future<List<CameraDescription>> _getAvailableCameras() async {
    if (_cachedCameras != null && _cachedCameras!.isNotEmpty) {
      return _cachedCameras!;
    }

    _camerasFuture ??= availableCameras();
    final cameras = await _camerasFuture!;
    _cachedCameras = cameras;
    if (cameras.isNotEmpty) {
      _camerasFuture = null;
    }
    return cameras;
  }

  Future<void> initialize() async {
    if (_isInitializing) return;
    if (state.controller?.value.isInitialized == true && state.isReady) return;

    try {
      _isInitializing = true;
      state = state.copyWith(status: ScannerStatus.loading);

      // Check camera permission
      final permissionStatus = await Permission.camera.request();

      if (permissionStatus != PermissionStatus.granted) {
        state = state.copyWith(
          status: ScannerStatus.permissionDenied,
          hasPermission: false,
          errorMessage: 'Camera permission is required to scan documents',
        );
        return;
      }

      // Get available cameras
      final cameras = await _getAvailableCameras();

      if (cameras.isEmpty) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: 'No cameras found on this device',
        );
        return;
      }

      state = state.copyWith(
        cameras: cameras,
        hasPermission: true,
      );

      final targetIndex = state.selectedCameraIndex < cameras.length
          ? state.selectedCameraIndex
          : 0;

      await setupCamera(targetIndex);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to initialize camera: ${e.toString()}',
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> setupCamera(int cameraIndex) async {
    try {
      if (state.cameras.isEmpty) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: 'No cameras available to setup',
        );
        return;
      }

      final maxIndex = state.cameras.length - 1;
      final targetIndex = cameraIndex < 0
          ? 0
          : (cameraIndex > maxIndex ? maxIndex : cameraIndex);

      if (state.controller != null &&
          state.controller!.description == state.cameras[targetIndex] &&
          state.controller!.value.isInitialized) {
        await state.controller!.setFlashMode(state.flashMode);
        state = state.copyWith(
          status: ScannerStatus.ready,
          selectedCameraIndex: targetIndex,
          errorMessage: null,
        );
        return;
      }

      if (state.controller != null) {
        await state.controller!.dispose();
      }

      final controller = CameraController(
        state.cameras[targetIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (controller.value.isInitialized) {
        await controller.setFlashMode(state.flashMode);

        state = state.copyWith(
          status: ScannerStatus.ready,
          selectedCameraIndex: targetIndex,
          errorMessage: null,
          controller: controller,
        );
      } else {
        throw Exception('Camera failed to initialize');
      }
    } catch (e) {
      debugPrint('Error setting up camera: $e');
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to setup camera: ${e.toString()}',
      );
    }
  }

  Future<String?> capturePhoto() async {
    if (!state.isReady || state.controller == null) return null;

    try {
      state = state.copyWith(status: ScannerStatus.capturing);

      final XFile photo = await state.controller!.takePicture();

      state = state.copyWith(status: ScannerStatus.ready);

      return photo.path;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to capture photo: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (!state.isReady || state.controller == null) return;

    try {
      final newFlashMode = switch (state.flashMode) {
        FlashMode.off => FlashMode.auto,
        FlashMode.auto => FlashMode.always,
        FlashMode.always => FlashMode.off,
        FlashMode.torch => FlashMode.off,
      };

      await state.controller!.setFlashMode(newFlashMode);
      state = state.copyWith(flashMode: newFlashMode);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> switchCamera() async {
    if (state.cameras.length < 2) return;

    final newIndex = (state.selectedCameraIndex + 1) % state.cameras.length;
    state = state.copyWith(status: ScannerStatus.loading);
    await setupCamera(newIndex);
  }

  Future<void> requestPermission() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      await initialize();
    }
  }

  void setProcessingProgress(double progress) {
    state = state.copyWith(
      status: ScannerStatus.processing,
      processingProgress: progress,
    );
  }

  void clearError() {
    state = state.copyWith(
      status: ScannerStatus.ready,
      errorMessage: null,
    );
  }
}
