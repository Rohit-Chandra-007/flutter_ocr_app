import 'dart:io';

import 'package:logger/logger.dart';
import 'package:pdfx/pdfx.dart';
import '../constants/app_constants.dart';
import '../utils/file_utils.dart';
import '../models/scan_page.dart';
import 'ocr_service.dart';

class PDFService {
  static final Logger _logger = Logger();
  // Legacy method for backward compatibility
  static Future<String> extractTextFromPDF(
    File pdfFile,
    Function(double) onProgress,
  ) async {
    final pages = await extractPagesFromPDF(pdfFile, onProgress);
    return pages.map((page) => page.extractedText).join('\n\n');
  }

  // Extract individual pages from PDF with OCR processing
  static Future<List<ScanPage>> extractPagesFromPDF(
    File pdfFile,
    Function(double) onProgress,
  ) async {
    _logger.i('PDF: Starting PDF extraction from: ${pdfFile.path}');
    List<ScanPage> pages = [];
    PdfDocument? pdf;

    try {
      _logger.d('PDF: Opening PDF document');
      pdf = await PdfDocument.openFile(pdfFile.path);
      final totalPages = pdf.pagesCount;
      _logger.i('PDF: PDF opened successfully. Total pages: $totalPages');

      for (var i = 1; i <= totalPages; i++) {
        PdfPage? page;
        try {
          _logger.d('PDF: Processing page $i/$totalPages');
          page = await pdf.getPage(i);
          _logger.d('PDF: Page $i retrieved, rendering...');

          // Render at high quality for better OCR on scanned documents
          final pageImage = await page.render(
            width: AppConstants.pdfRenderWidth.toDouble(),
            height: AppConstants.pdfRenderHeight.toDouble(),
            format: PdfPageImageFormat.png, // PNG for lossless quality
            backgroundColor: '#FFFFFF', // White background
          );
          _logger.d('PDF: Page $i rendered');

          if (pageImage?.bytes != null && pageImage!.bytes.isNotEmpty) {
            _logger.d(
                'PDF: Writing page $i image to temp file (${pageImage.bytes.length} bytes)');
            final imagePath = await FileUtils.getTempImagePath(i);
            await FileUtils.writeImageBytes(imagePath, pageImage.bytes);
            _logger.d('PDF: Page $i image written to: $imagePath');

            // Verify file was written successfully
            final file = File(imagePath);
            if (!await file.exists()) {
              _logger.e('PDF: Failed to write image file for page $i');
              continue;
            }

            // Create page and process OCR immediately
            _logger.d('PDF: Creating ScanPage for page $i');
            final scanPage = ScanPage.create(
              imagePath: imagePath,
              pageNumber: i,
            );

            // Process OCR during upload
            try {
              _logger.d('PDF: Starting OCR for page $i');
              final text = await OCRService.extractTextFromImage(imagePath);
              _logger.d(
                  'PDF: OCR completed for page $i, text length: ${text.length}');

              if (text.isNotEmpty) {
                scanPage.updateWithOcrText(text);
                _logger.d('PDF: Page $i updated with OCR text');
              }
            } catch (ocrError, stackTrace) {
              _logger.e('PDF: OCR error for page $i',
                  error: ocrError, stackTrace: stackTrace);
              // Continue without OCR text
            }

            pages.add(scanPage);
            _logger.i('PDF: Page $i processed successfully');
            onProgress(i / totalPages);

            // Add delay between pages to prevent buffer overflow
            if (i < totalPages) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
          } else {
            _logger.w('PDF: Page $i has no image bytes');
          }
        } catch (pageError, stackTrace) {
          _logger.e('PDF: Error processing page $i',
              error: pageError, stackTrace: stackTrace);
          // Continue to next page
        } finally {
          // Always close the page to release resources
          await page?.close();
        }
      }

      if (pages.isEmpty) {
        _logger.e('PDF: No pages could be extracted from PDF');
        throw Exception('No pages could be extracted from PDF');
      }

      _logger.i(
          'PDF: PDF document closed. Total pages extracted: ${pages.length}');
      return pages;
    } catch (e, stackTrace) {
      _logger.e('PDF: Processing Error', error: e, stackTrace: stackTrace);
      throw Exception('PDF Processing Error: ${e.toString()}');
    } finally {
      // Always close the PDF document
      await pdf?.close();
    }
  }
}
