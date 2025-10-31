import 'package:camera/camera.dart';
import 'package:scanflow/core/constants/app_enum.dart';

class ScannerState {
  final ScannerStatus status;
  final List<CameraDescription> cameras;
  final int selectedCameraIndex;
  final FlashMode flashMode;
  final bool hasPermission;
  final String? errorMessage;
  final double processingProgress;

  const ScannerState({
    this.status = ScannerStatus.initial,
    this.cameras = const [],
    this.selectedCameraIndex = 0,
    this.flashMode = FlashMode.off,
    this.hasPermission = false,
    this.errorMessage,
    this.processingProgress = 0.0,
  });

  bool get isLoading => status == ScannerStatus.loading;
  bool get isReady => status == ScannerStatus.ready;
  bool get isCapturing => status == ScannerStatus.capturing;
  bool get isProcessing => status == ScannerStatus.processing;
  bool get hasError => status == ScannerStatus.error;
  bool get needsPermission => status == ScannerStatus.permissionDenied;

  ScannerState copyWith({
    ScannerStatus? status,
    List<CameraDescription>? cameras,
    int? selectedCameraIndex,
    FlashMode? flashMode,
    bool? hasPermission,
    String? errorMessage,
    double? processingProgress,
  }) {
    return ScannerState(
      status: status ?? this.status,
      cameras: cameras ?? this.cameras,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      flashMode: flashMode ?? this.flashMode,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage,
      processingProgress: processingProgress ?? this.processingProgress,
    );
  }
}
