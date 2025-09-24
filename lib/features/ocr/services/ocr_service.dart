import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
  
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}