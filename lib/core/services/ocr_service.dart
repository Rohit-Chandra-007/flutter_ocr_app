import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';
import '../models/scan_page.dart';
import '../utils/file_utils.dart';

class OCRService {
  static final Logger _logger = Logger();

  // Text recognizers for different scripts
  // Latin recognizer (English, European languages)
  static final TextRecognizer _latinRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  // Devanagiri recognizer (Hindi, Marathi, Sanskrit, Nepali)
  static final TextRecognizer _devanagiriRecognizer =
      TextRecognizer(script: TextRecognitionScript.devanagiri);

  /// Extract text from a single image using both Latin and Devanagari recognizers.
  /// This method tries both scripts and combines the results for maximum text extraction.
  /// Supports:
  /// - Latin scripts (English, Spanish, French, German, etc.)
  /// - Devanagari (Hindi, Marathi, Sanskrit, Nepali)
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      _logger.i('OCR: Starting multi-language text extraction for: $imagePath');

      // Validate image file
      if (!await FileUtils.isValidImageFile(imagePath)) {
        _logger.e('OCR: Invalid or corrupted image file: $imagePath');
        return '';
      }

      // Check file size (skip if too large - over 10MB)
      final file = File(imagePath);
      final fileSize = await file.length();
      _logger.d(
          'OCR: File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      if (fileSize > 10 * 1024 * 1024) {
        _logger.w(
            'OCR: File too large for processing: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        return '';
      }

      // Create InputImage with error handling
      final InputImage inputImage;
      try {
        inputImage = InputImage.fromFilePath(imagePath);
        _logger.d('OCR: InputImage created successfully');
      } catch (e) {
        _logger.e('OCR: Failed to create InputImage from path: $e');
        return '';
      }

      // Try both Latin and Devanagari recognizers
      final results = <String>[];

      // Try Latin script first
      try {
        _logger.d('OCR: Processing with Latin recognizer');
        final latinResult = await _latinRecognizer.processImage(inputImage);
        if (latinResult.text.isNotEmpty) {
          results.add(latinResult.text);
          _logger
              .d('OCR: Latin text extracted: ${latinResult.text.length} chars');
        }
      } catch (e) {
        _logger.w('OCR: Latin recognition failed: $e');
      }

      // Try Devanagiri script (Hindi)
      try {
        _logger.d('OCR: Processing with Devanagiri recognizer');
        final devanagiriResult =
            await _devanagiriRecognizer.processImage(inputImage);
        if (devanagiriResult.text.isNotEmpty) {
          results.add(devanagiriResult.text);
          _logger.d(
              'OCR: Devanagiri text extracted: ${devanagiriResult.text.length} chars');
        }
      } catch (e) {
        _logger.w('OCR: Devanagiri recognition failed: $e');
      }

      // Combine results
      final combinedText = results.join('\n\n');

      _logger.i(
          'OCR: Multi-language extraction completed. Total length: ${combinedText.length}');

      return combinedText;
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
        } else {
          _logger.w('OCR: No text extracted for page ${i + 1}');
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
    await _latinRecognizer.close();
    await _devanagiriRecognizer.close();
  }
}
