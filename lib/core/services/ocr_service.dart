import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/scan_page.dart';

// Data class to pass both token and image path to isolate
class _IsolateData {
  final RootIsolateToken rootIsolateToken;
  final String imagePath;

  _IsolateData(this.rootIsolateToken, this.imagePath);
}

// Top-level function for compute isolate
Future<String> _extractTextInIsolate(_IsolateData data) async {
  // Initialize the binary messenger for background isolate
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);

  final textRecognizer = TextRecognizer();
  try {
    final inputImage = InputImage.fromFilePath(data.imagePath);
    final result = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return result.text;
  } catch (e) {
    throw Exception('Image Processing Error: ${e.toString()}');
  }
}

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from a single image using compute (runs on separate isolate)
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      // Get the root isolate token to pass to background isolate
      final rootIsolateToken = ServicesBinding.rootIsolateToken;
      if (rootIsolateToken == null) {
        throw Exception('Root isolate token is null');
      }

      // Run OCR on separate isolate for better performance
      final data = _IsolateData(rootIsolateToken, imagePath);
      return await compute(_extractTextInIsolate, data);
    } catch (e) {
      throw Exception('Image Processing Error: ${e.toString()}');
    }
  }

  /// Process multiple images with OCR during upload
  /// Uses compute for each image to keep UI responsive
  static Future<List<ScanPage>> processMultipleImages(
    List<String> imagePaths,
    Function(double)? onProgress,
  ) async {
    List<ScanPage> pages = [];

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final page = ScanPage.create(
          imagePath: imagePaths[i],
          pageNumber: i + 1,
        );

        // Process OCR on separate isolate (non-blocking)
        final extractedText = await extractTextFromImage(imagePaths[i]);
        page.updateWithOcrText(extractedText);

        pages.add(page);

        // Report progress
        if (onProgress != null) {
          onProgress((i + 1) / imagePaths.length);
        }
      } catch (e) {
        // Create page with error message if OCR fails
        final page = ScanPage.create(
          imagePath: imagePaths[i],
          pageNumber: i + 1,
        );
        page.updateWithOcrText(
            'Error processing page ${i + 1}: ${e.toString()}');
        pages.add(page);
      }
    }

    return pages;
  }

  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
