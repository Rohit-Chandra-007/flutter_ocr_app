import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scan_document.dart';

class DatabaseService {
  static final Logger _logger = Logger();
  static Isar? _isar;

  // Get the Isar instance, initialize if needed
  static Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ScanDocumentSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  // Initialize the database (call this in main.dart)
  static Future<void> initialize() async {
    await isar; // This will initialize the database
  }

  // Save or Update a scan document
  static Future<void> saveScanDocument(ScanDocument document) async {
    try {
      _logger.i('Database: Saving document: ${document.title}');
      _logger.d(
          'Database: Document ID: ${document.id}, Pages: ${document.pages.length}');

      final db = await isar;
      _logger.d('Database: Isar instance obtained');

      await db.writeTxn(() async {
        _logger.d('Database: Starting write transaction');
        final id = await db.scanDocuments.put(document);
        _logger.i('Database: Document saved with ID: $id');
      });

      _logger.i('Database: Transaction completed successfully');
    } catch (e, stackTrace) {
      _logger.e('Database: Error saving document',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get all scan documents, sorted by newest first
  static Future<List<ScanDocument>> getAllScanDocuments() async {
    final db = await isar;
    return await db.scanDocuments.where().sortByCreatedAtDesc().findAll();
  }

  // Delete a scan document by its Id
  static Future<void> deleteScanDocument(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.scanDocuments.delete(id);
    });
  }

  // Search documents using the full-text index
  static Future<List<ScanDocument>> searchScanDocuments(String query) async {
    final db = await isar;
    return await db.scanDocuments
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .extractedTextContains(query, caseSensitive: false)
        .findAll();
  }
}
