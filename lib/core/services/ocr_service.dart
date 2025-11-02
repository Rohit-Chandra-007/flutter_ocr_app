
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';
import '../models/scan_page.dart';

class OCRService {
  static final Logger _logger = Logger();
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from a single image on the main isolate.
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      _logger.i('OCR: Starting text extraction for: $imagePath');
      final inputImage = InputImage.fromFilePath(imagePath);
      _logger.d('OCR: InputImage created successfully');

      final result = await _textRecognizer.processImage(inputImage);
      _logger
          .i('OCR: Text extraction completed. Length: ${result.text.length}');

      return result.text;
    } catch (e, stackTrace) {
      _logger.e('OCR: Error extracting text from image',
          error: e, stackTrace: stackTrace);
      // Return empty string instead of throwing to prevent crashes
      return '';
    }
  }

  /// Process multiple images with OCR during upload.
  static Future<List<ScanPage>> processMultipleImages(
    List<String> imagePaths,
    Function(double)? onProgress,
  ) async {
    _logger.i('OCR: Processing ${imagePaths.length} images');
    List<ScanPage> pages = [];

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        _logger.d('OCR: Creating page ${i + 1} for path: ${imagePaths[i]}');
        final page = ScanPage.create(
          imagePath: imagePaths[i],
          pageNumber: i + 1,
        );
        _logger.d('OCR: Page ${i + 1} created successfully');

        _logger.d('OCR: Starting text extraction for page ${i + 1}');
        final extractedText = await extractTextFromImage(imagePaths[i]);
        _logger.d(
            'OCR: Text extracted for page ${i + 1}, length: ${extractedText.length}');

        if (extractedText.isNotEmpty) {
          page.updateWithOcrText(extractedText);
          _logger.d('OCR: Page ${i + 1} updated with OCR text');
        }

        pages.add(page);
        _logger.i('OCR: Page ${i + 1} processed successfully');

        // Add small delay between processing to prevent buffer overflow
        if (i < imagePaths.length - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Report progress
        if (onProgress != null) {
          onProgress((i + 1) / imagePaths.length);
        }
      } catch (e, stackTrace) {
        _logger.e('OCR: Error processing page ${i + 1}',
            error: e, stackTrace: stackTrace);
        // Create page without OCR text if processing fails
        final page = ScanPage.create(
          imagePath: imagePaths[i],
          pageNumber: i + 1,
        );
        pages.add(page);
        _logger.w('OCR: Page ${i + 1} added without OCR text');
      }
    }

    _logger.i(
        'OCR: Completed processing all images. Total pages: ${pages.length}');
    return pages;
  }

  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
