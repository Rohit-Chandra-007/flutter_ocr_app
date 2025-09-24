import 'dart:io';
import 'package:pdfx/pdfx.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/file_utils.dart';
import 'ocr_service.dart';

class PDFService {
  static Future<String> extractTextFromPDF(
    File pdfFile, 
    Function(double) onProgress,
  ) async {
    String extractedText = '';
    
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
          
          final text = await OCRService.extractTextFromImage(imagePath);
          extractedText += text;
          
          onProgress(i / totalPages);
        }
        
        await page.close();
      }
      
      await pdf.close();
      return extractedText;
    } catch (e) {
      throw Exception('PDF Processing Error: ${e.toString()}');
    }
  }
}