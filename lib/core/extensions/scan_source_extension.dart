import 'package:scanflow/core/constants/app_enum.dart';

extension ScanSourceExtension on ScanSource {
  String get label {
    switch (this) {
      case ScanSource.camera:
        return 'Camera';
      case ScanSource.gallery:
        return 'Gallery';
      case ScanSource.pdf:
        return 'PDF File';
      case ScanSource.multipleImages:
        return 'Images';
    }
  }

  String get subtitle {
    switch (this) {
      case ScanSource.camera:
        return 'Take a photo';
      case ScanSource.gallery:
        return 'Choose image';
      case ScanSource.pdf:
        return 'Import PDF';
      case ScanSource.multipleImages:
        return 'Batch scan';
    }
  }
}
