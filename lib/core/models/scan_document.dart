import 'package:isar/isar.dart';
part 'scan_document.g.dart';

@collection
class ScanDocument {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String title;

  @Index(type: IndexType.value)
  late String extractedText;

  @Index() // Indexing createdAt for fast sorting
  late DateTime createdAt;

  late DateTime updatedAt;
  List<String> imagePaths = [];
  late int pageCount;
  late String previewText;

  ScanDocument();

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
