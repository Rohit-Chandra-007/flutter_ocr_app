enum ScanSource {
  camera,
  gallery,
  pdf,
  multipleImages,
}

enum ScannerStatus {
  initial,
  loading,
  ready,
  capturing,
  processing,
  error,
  permissionDenied,
}
