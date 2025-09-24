import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getTempImagePath(int pageNumber) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/page_$pageNumber.png';
  }
  
  static Future<void> writeImageBytes(String path, List<int> bytes) async {
    await File(path).writeAsBytes(bytes);
  }
  
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }
}