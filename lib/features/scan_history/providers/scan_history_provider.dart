import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/scan_document.dart';
import '../../../core/services/database_service.dart';

part 'scan_history_provider.g.dart';

@riverpod
class ScanHistory extends _$ScanHistory {
  @override
  Future<List<ScanDocument>> build() async {
    return await _loadScanHistory();
  }

  Future<List<ScanDocument>> _loadScanHistory() async {
    final documents = await DatabaseService.getAllScanDocuments();

    // Load sample data if no documents exist
    // if (documents.isEmpty) {
    //   final sampleDocs = SampleDataService.getSampleDocuments();
    //   for (final doc in sampleDocs) {
    //     await DatabaseService.saveScanDocument(doc);
    //   }
    //   return await DatabaseService.getAllScanDocuments();
    // }

    return documents;
  }

  Future<void> addScanDocument(ScanDocument document) async {
    await DatabaseService.saveScanDocument(document);
    ref.invalidateSelf();
  }

  Future<void> updateScanDocument(ScanDocument document) async {
    await DatabaseService.saveScanDocument(
        document); // Save handles both create and update
    ref.invalidateSelf();
  }

  Future<void> deleteScanDocument(int id) async {
    await DatabaseService.deleteScanDocument(id);
    ref.invalidateSelf();
  }

  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await DatabaseService.searchScanDocuments(query);
    });
  }
}
