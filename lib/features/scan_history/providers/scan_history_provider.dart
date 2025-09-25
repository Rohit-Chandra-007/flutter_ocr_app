import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scan_document.dart';
import '../../../core/services/database_service.dart';

final scanHistoryProvider = StateNotifierProvider<ScanHistoryNotifier, AsyncValue<List<ScanDocument>>>((ref) {
  return ScanHistoryNotifier();
});

class ScanHistoryNotifier extends StateNotifier<AsyncValue<List<ScanDocument>>> {
  ScanHistoryNotifier() : super(const AsyncValue.loading()) {
    loadScanHistory();
  }
  
  Future<void> loadScanHistory() async {
    try {
      state = const AsyncValue.loading();
      var documents = await DatabaseService.getAllScanDocuments();
      
      // Load sample data if no documents exist
      // if (documents.isEmpty) {
      //   final sampleDocs = SampleDataService.getSampleDocuments();
      //   for (final doc in sampleDocs) {
      //     await DatabaseService.saveScanDocument(doc);
      //   }
      //   documents = await DatabaseService.getAllScanDocuments();
      // }
      
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addScanDocument(ScanDocument document) async {
    try {
      await DatabaseService.saveScanDocument(document);
      await loadScanHistory(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateScanDocument(ScanDocument document) async {
    try {
      await DatabaseService.saveScanDocument(document); // Save handles both create and update
      await loadScanHistory(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteScanDocument(int id) async {
    try {
      await DatabaseService.deleteScanDocument(id);
      await loadScanHistory(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      await loadScanHistory();
      return;
    }
    
    try {
      state = const AsyncValue.loading();
      final documents = await DatabaseService.searchScanDocuments(query);
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}