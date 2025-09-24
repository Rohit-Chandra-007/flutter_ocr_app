import 'package:uuid/uuid.dart';

class ScanDocument {
  final String id;
  String title;
  String extractedText;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<String> imagePaths;
  int pageCount;
  String previewText;
  
  ScanDocument({
    String? id,
    required this.title,
    required this.extractedText,
    required this.imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       pageCount = imagePaths.length,
       previewText = extractedText.length > 100 
           ? '${extractedText.substring(0, 100)}...'
           : extractedText;
  
  void updateText(String newText) {
    extractedText = newText;
    updatedAt = DateTime.now();
    previewText = newText.length > 100 
        ? '${newText.substring(0, 100)}...'
        : newText;
  }
  
  void updateTitle(String newTitle) {
    title = newTitle;
    updatedAt = DateTime.now();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'extractedText': extractedText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imagePaths': imagePaths,
      'pageCount': pageCount,
      'previewText': previewText,
    };
  }
  
  factory ScanDocument.fromJson(Map<String, dynamic> json) {
    return ScanDocument(
      id: json['id'],
      title: json['title'],
      extractedText: json['extractedText'],
      imagePaths: List<String>.from(json['imagePaths']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}