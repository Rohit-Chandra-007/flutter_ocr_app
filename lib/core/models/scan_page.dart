import 'package:isar/isar.dart';
part 'scan_page.g.dart';

@embedded
class ScanPage {
  late String imagePath;
  String extractedText = ''; // Empty by default - OCR on demand
  late int pageNumber;
  late DateTime createdAt;
  DateTime? ocrProcessedAt; // Null if OCR not yet performed
  bool isOcrProcessed = false; // Track if OCR has been performed

  ScanPage();

  ScanPage.create({
    required this.imagePath,
    required this.pageNumber,
  }) {
    createdAt = DateTime.now();
    extractedText = '';
    isOcrProcessed = false;
    ocrProcessedAt = null;
  }

  // Method to update with OCR results
  void updateWithOcrText(String text) {
    extractedText = text;
    isOcrProcessed = true;
    ocrProcessedAt = DateTime.now();
  }
}