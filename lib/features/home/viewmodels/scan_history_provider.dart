import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/scan_document.dart';
import '../../../core/services/database_service.dart';

part 'scan_history_provider.g.dart';

@riverpod
class ScanHistory extends _$ScanHistory {
  static final Logger _logger = Logger();
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
    try {
      _logger.i('ScanHistory: Adding document: ${document.title}');
      _logger.d('ScanHistory: Document has ${document.pages.length} pages');

      await DatabaseService.saveScanDocument(document);
      _logger.i('ScanHistory: Document saved to database successfully');

      ref.invalidateSelf();
      _logger.d('ScanHistory: Provider invalidated');
    } catch (e, stackTrace) {
      _logger.e('ScanHistory: Error adding document',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
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
