import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:pdfx/pdfx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/core.dart';
import '../../home/viewmodels/scan_history_provider.dart';

part 'document_processor_provider.g.dart';

@riverpod
class DocumentProcessor extends _$DocumentProcessor {
  static final Logger _logger = Logger();

  @override
  FutureOr<void> build() {
    // Keep provider alive during async operations
    ref.keepAlive();
  }

  Future<bool> processImageFromCamera(String imagePath) async {
    try {
      _logger.i('DocProcessor: Processing camera image: $imagePath');
      if (imagePath.isEmpty) {
        _logger.e('DocProcessor: Invalid image path - empty string');
        throw Exception('Invalid image path');
      }
      final result = await _processImages([imagePath], 'Scanned Document');
      _logger.i('DocProcessor: Camera image processed successfully: $result');
      return result;
    } catch (e, stackTrace) {
      _logger.e('DocProcessor: Error processing camera image',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> processImageFromGallery() async {
    try {
      _logger.i('DocProcessor: Starting gallery image picker');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        _logger.w('DocProcessor: No image selected from gallery');
        return false;
      }

      _logger.i('DocProcessor: Gallery image selected: ${image.path}');
      return await _processImages([image.path], 'Scanned Document');
    } catch (e, stackTrace) {
      _logger.e('DocProcessor: Error picking image',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> processMultipleImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final files = result.files.where((file) => file.path != null).toList();

      if (files.isEmpty) return false;

      // Check page limit
      if (files.length > AppConstants.maxPagesPerDocument) {
        throw Exception(
          'Selected ${files.length} images, but maximum is ${AppConstants.maxPagesPerDocument} pages',
        );
      }

      final imagePaths = files.map((file) => file.path!).toList();
      final title = 'Multi-page Document (${files.length} pages)';

      return await _processImages(imagePaths, title);
    } catch (e) {
      debugPrint('Error processing multiple images: $e');
      rethrow;
    }
  }

  Future<bool> processPDF() async {
    try {
      _logger.i('DocProcessor: Starting PDF processing');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        _logger.w('DocProcessor: No PDF file selected');
        return false;
      }

      _logger.i('DocProcessor: PDF file selected: ${result.files.single.name}');
      final file = File(result.files.single.path!);

      // Check PDF page count
      _logger.d('DocProcessor: Checking PDF page count');
      final pdfDoc = await PdfDocument.openFile(file.path);
      final pageCount = pdfDoc.pagesCount;
      await pdfDoc.close();
      _logger.i('DocProcessor: PDF has $pageCount pages');

      // Check page limit
      if (pageCount > AppConstants.maxPagesPerDocument) {
        _logger.e(
            'DocProcessor: PDF exceeds page limit: $pageCount > ${AppConstants.maxPagesPerDocument}');
        throw Exception(
          'PDF has $pageCount pages, but maximum is ${AppConstants.maxPagesPerDocument} pages',
        );
      }

      // Extract pages from PDF
      _logger.d('DocProcessor: Extracting pages from PDF');
      final pages = await PDFService.extractPagesFromPDF(file, (progress) {});
      _logger.i('DocProcessor: PDF pages extracted: ${pages.length}');

      // Check if provider is still mounted after async work
      if (!ref.mounted) {
        _logger.w('DocProcessor: Provider not mounted after PDF extraction');
        return false;
      }

      // Create document title from filename
      String title = result.files.single.name.replaceAll('.pdf', '');
      _logger.d('DocProcessor: Creating document with title: $title');

      // Create and save document
      _logger.d('DocProcessor: Creating ScanDocument from PDF pages');
      final document = ScanDocument.createFromPages(
        title: title,
        pages: pages,
      );
      _logger.i(
          'DocProcessor: ScanDocument created with ${document.pages.length} pages');

      _logger.d('DocProcessor: Saving PDF document to database');
      await ref.read(scanHistoryProvider.notifier).addScanDocument(document);
      _logger.i('DocProcessor: PDF document saved successfully');

      return true;
    } catch (e, stackTrace) {
      _logger.e('DocProcessor: Error processing PDF',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> _processImages(
    List<String> imagePaths,
    String defaultTitle,
  ) async {
    try {
      _logger.i(
          'DocProcessor: _processImages called with ${imagePaths.length} paths');

      // Validate image paths
      if (imagePaths.isEmpty) {
        _logger.e('DocProcessor: No images to process');
        throw Exception('No images to process');
      }

      _logger.d('DocProcessor: Starting OCR processing');
      // Process images with OCR
      final pages = await OCRService.processMultipleImages(imagePaths, null);
      _logger.i(
          'DocProcessor: OCR processing completed. Pages created: ${pages.length}');

      // Check if provider is still mounted after async work
      if (!ref.mounted) {
        _logger.w('DocProcessor: Provider not mounted after OCR processing');
        return false;
      }

      // Validate pages were created
      if (pages.isEmpty) {
        _logger.e('DocProcessor: Failed to create pages from images');
        throw Exception('Failed to create pages from images');
      }

      // Generate title from extracted text if available
      _logger.d('DocProcessor: Generating document title');
      String title = defaultTitle;
      if (pages.isNotEmpty && pages.first.extractedText.isNotEmpty) {
        final words = pages.first.extractedText.split(' ').take(4).join(' ');
        if (words.isNotEmpty) {
          title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
        }
      }
      _logger.d('DocProcessor: Document title: $title');

      // Create and save document
      _logger.d('DocProcessor: Creating ScanDocument');
      final document = ScanDocument.createFromPages(
        title: title,
        pages: pages,
      );
      _logger.i('DocProcessor: ScanDocument created with ID: ${document.id}');

      _logger.d('DocProcessor: Saving document to database');
      await ref.read(scanHistoryProvider.notifier).addScanDocument(document);
      _logger.i('DocProcessor: Document saved successfully');

      return true;
    } catch (e, stackTrace) {
      _logger.e('DocProcessor: Error processing images',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
