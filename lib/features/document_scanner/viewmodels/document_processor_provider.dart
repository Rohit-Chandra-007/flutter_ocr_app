import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../core/core.dart';
import '../../home/viewmodels/scan_history_provider.dart';

part 'document_processor_provider.g.dart';

@Riverpod(keepAlive: true)
class DocumentProcessor extends _$DocumentProcessor {
  @override
  FutureOr<void> build() {}

  Future<bool> processImageFromCamera(String imagePath) async {
    return await _processImages([imagePath], 'Scanned Document');
  }

  Future<bool> processImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return false;

      return await _processImages([image.path], 'Scanned Document');
    } catch (e) {
      debugPrint('Error picking image: $e');
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);

      // Check PDF page count
      final pdfDoc = await PdfDocument.openFile(file.path);
      final pageCount = pdfDoc.pagesCount;
      await pdfDoc.close();

      // Check page limit
      if (pageCount > AppConstants.maxPagesPerDocument) {
        throw Exception(
          'PDF has $pageCount pages, but maximum is ${AppConstants.maxPagesPerDocument} pages',
        );
      }

      // Extract pages from PDF
      final pages = await PDFService.extractPagesFromPDF(file, (progress) {});

      // Check if provider is still mounted after async work
      if (!ref.mounted) return false;

      // Create document title from filename
      String title = result.files.single.name.replaceAll('.pdf', '');

      // Create and save document
      final document = ScanDocument.createFromPages(
        title: title,
        pages: pages,
      );

      await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

      return true;
    } catch (e) {
      debugPrint('Error processing PDF: $e');
      rethrow;
    }
  }

  Future<bool> _processImages(
    List<String> imagePaths,
    String defaultTitle,
  ) async {
    try {
      // Process images with OCR
      final pages = await OCRService.processMultipleImages(imagePaths, null);

      // Check if provider is still mounted after async work
      if (!ref.mounted) return false;

      // Generate title from extracted text if available
      String title = defaultTitle;
      if (pages.isNotEmpty && pages.first.extractedText.isNotEmpty) {
        final words = pages.first.extractedText.split(' ').take(4).join(' ');
        if (words.isNotEmpty) {
          title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
        }
      }

      // Create and save document
      final document = ScanDocument.createFromPages(
        title: title,
        pages: pages,
      );

      await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

      return true;
    } catch (e) {
      debugPrint('Error processing images: $e');
      rethrow;
    }
  }
}
