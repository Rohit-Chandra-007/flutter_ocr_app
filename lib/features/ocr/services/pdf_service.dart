import 'dart:io';
import 'package:pdfx/pdfx.dart';
import 'package:scanflow/features/ocr/services/ocr_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/file_utils.dart';
import '../../../core/models/scan_page.dart';


class PDFService {
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
    List<ScanPage> pages = [];
    
    try {
      final pdf = await PdfDocument.openFile(pdfFile.path);
      final totalPages = pdf.pagesCount;

      for (var i = 1; i <= totalPages; i++) {
        final page = await pdf.getPage(i);
        final pageImage = await page.render(
          width: AppConstants.pdfRenderWidth.toDouble(),
          height: AppConstants.pdfRenderHeight.toDouble(),
        );
        
        if (pageImage?.bytes != null) {
          final imagePath = await FileUtils.getTempImagePath(i);
          await FileUtils.writeImageBytes(imagePath, pageImage!.bytes);
          
          // Create page and process OCR immediately
          final scanPage = ScanPage.create(
            imagePath: imagePath,
            pageNumber: i,
          );
          
          // Process OCR during upload
          final text = await OCRService.extractTextFromImage(imagePath);
          scanPage.updateWithOcrText(text);
          
          pages.add(scanPage);
          onProgress(i / totalPages);
        }
        
        await page.close();
      }
      
      await pdf.close();
      return pages;
    } catch (e) {
      throw Exception('PDF Processing Error: ${e.toString()}');
    }
  }
}