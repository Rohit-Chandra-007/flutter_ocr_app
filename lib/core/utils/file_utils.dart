import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static final Logger _logger = Logger();

  static Future<String> getTempImagePath(int pageNumber) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${tempDir.path}/page_${pageNumber}_$timestamp.png';
  }

  static Future<void> writeImageBytes(String path, List<int> bytes) async {
    try {
      if (bytes.isEmpty) {
        _logger.e('FileUtils: Cannot write empty bytes to $path');
        throw Exception('Empty image bytes');
      }

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      // Verify write was successful
      if (!await file.exists()) {
        _logger.e('FileUtils: File not found after write: $path');
        throw Exception('Failed to write file');
      }

      final writtenSize = await file.length();
      _logger.d('FileUtils: Successfully wrote $writtenSize bytes to $path');
    } catch (e, stackTrace) {
      _logger.e('FileUtils: Error writing image bytes',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  static Future<bool> isValidImageFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;

      final size = await file.length();
      if (size == 0) {
        _logger.w('FileUtils: Image file is empty: $path');
        return false;
      }

      // Check file extension
      final extension = path.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        _logger.w('FileUtils: Unsupported image format: $extension');
        return false;
      }

      return true;
    } catch (e) {
      _logger.e('FileUtils: Error validating image file: $e');
      return false;
    }
  }
}
