import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_document.dart';

class DatabaseService {
  static const String _documentsKey = 'scan_documents';
  
  // Save a new scan document
  static Future<void> saveScanDocument(ScanDocument document) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await getAllScanDocuments();
    
    // Remove existing document with same ID if it exists
    documents.removeWhere((doc) => doc.id == document.id);
    
    // Add the new/updated document
    documents.insert(0, document);
    
    // Save to preferences
    final jsonList = documents.map((doc) => doc.toJson()).toList();
    await prefs.setString(_documentsKey, jsonEncode(jsonList));
  }
  
  // Get all scan documents ordered by creation date
  static Future<List<ScanDocument>> getAllScanDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_documentsKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    final documents = jsonList
        .map((json) => ScanDocument.fromJson(json))
        .toList();
    
    // Sort by creation date (newest first)
    documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return documents;
  }
  
  // Update a scan document
  static Future<void> updateScanDocument(ScanDocument document) async {
    await saveScanDocument(document); // Same as save for this implementation
  }
  
  // Delete a scan document
  static Future<void> deleteScanDocument(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await getAllScanDocuments();
    
    documents.removeWhere((doc) => doc.id == id);
    
    final jsonList = documents.map((doc) => doc.toJson()).toList();
    await prefs.setString(_documentsKey, jsonEncode(jsonList));
  }
  
  // Search scan documents by title or content
  static Future<List<ScanDocument>> searchScanDocuments(String query) async {
    final documents = await getAllScanDocuments();
    final lowercaseQuery = query.toLowerCase();
    
    return documents.where((doc) {
      return doc.title.toLowerCase().contains(lowercaseQuery) ||
             doc.extractedText.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}