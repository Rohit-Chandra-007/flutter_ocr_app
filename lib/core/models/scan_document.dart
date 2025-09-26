import 'package:isar/isar.dart';
import 'scan_page.dart';
part 'scan_document.g.dart';

@collection
class ScanDocument {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String title;

  @Index(type: IndexType.value)
  late String extractedText; // Combined text for search purposes

  @Index() // Indexing createdAt for fast sorting
  late DateTime createdAt;

  late DateTime updatedAt;
  
  // New structure: individual pages with their own image-text pairs
  List<ScanPage> pages = [];
  
  // Legacy support - will be deprecated
  List<String> imagePaths = [];
  late int pageCount;
  late String previewText;

  ScanDocument();

  // New constructor using individual pages
  ScanDocument.createFromPages({
    required this.title,
    required this.pages,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    pageCount = pages.length;
    
    // Only combine texts from pages that have been OCR processed
    final processedTexts = pages
        .where((page) => page.isOcrProcessed && page.extractedText.isNotEmpty)
        .map((page) => page.extractedText);
    
    extractedText = processedTexts.join('\n\n');
    
    // Legacy support
    imagePaths = pages.map((page) => page.imagePath).toList();
    
    previewText = extractedText.length > 100
        ? '${extractedText.substring(0, 100)}...'
        : 'Document with ${pages.length} pages - Click pages to extract text';
  }

  // Method to update combined text when pages are OCR processed
  void updateCombinedText() {
    final processedTexts = pages
        .where((page) => page.isOcrProcessed && page.extractedText.isNotEmpty)
        .map((page) => page.extractedText);
    
    extractedText = processedTexts.join('\n\n');
    updatedAt = DateTime.now();
    
    previewText = extractedText.length > 100
        ? '${extractedText.substring(0, 100)}...'
        : extractedText.isEmpty 
            ? 'Document with ${pages.length} pages - Click pages to extract text'
            : extractedText;
  }

  // Legacy constructor for backward compatibility
  ScanDocument.create({
    required this.title,
    required this.extractedText,
    required this.imagePaths,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    pageCount = imagePaths.length;
    previewText = extractedText.length > 100
        ? '${extractedText.substring(0, 100)}...'
        : extractedText;
    
    // Convert to new structure
    pages = imagePaths.asMap().entries.map((entry) {
      final page = ScanPage.create(
        imagePath: entry.value,
        pageNumber: entry.key + 1,
      );
      // For legacy support, mark as processed with the combined text
      if (extractedText.isNotEmpty) {
        page.updateWithOcrText(extractedText);
      }
      return page;
    }).toList();
  }

  void updateText(String newText) {
    extractedText = newText;
    updatedAt = DateTime.now();
    previewText =
        newText.length > 100 ? '${newText.substring(0, 100)}...' : newText;
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    updatedAt = DateTime.now();
  }
}
