import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/models/scan_page.dart';

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();
  
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await _textRecognizer.processImage(inputImage);
      return result.text;
    } catch (e) {
      throw Exception('Image Processing Error: ${e.toString()}');
    }
  }
  
  // Process multiple images with OCR during upload
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
        
        // Process OCR immediately
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
        page.updateWithOcrText('Error processing page ${i + 1}: ${e.toString()}');
        pages.add(page);
      }
    }
    
    return pages;
  }
  
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}