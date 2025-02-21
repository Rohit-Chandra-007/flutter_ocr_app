import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File;
import 'components/file_picker_menu.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen>
    with SingleTickerProviderStateMixin {
  String extractedText = '';
  bool isLoading = false;
  double progress = 0;
  late AnimationController _animationController;
  final TextEditingController _textEditingController = TextEditingController();
  bool _isEditing = false;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _processPdf(File pdfFile) async {
    try {
      final pdf = await PdfDocument.openFile(pdfFile.path);
      final totalPages = pdf.pagesCount;

      for (var i = 1; i <= totalPages; i++) {
        final page = await pdf.getPage(i);
        final pageImage = await page.render(width: 2000, height: 3000);
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/page_$i.png';

        // Write the raw bytes directly instead of converting via toImage()
        if (pageImage?.bytes != null) {
          await File(path).writeAsBytes(pageImage!.bytes);
        }

        final text = await _processImage(path);
        setState(() {
          extractedText += text;
          progress = i / totalPages;
        });

        // Dispose of the page resource after processing
        await page.close();
      }
      // Close the PDF document after processing all pages
      await pdf.close();
    } catch (e) {
      _showError('PDF Processing Error: ${e.toString()}');
    }
  }

  Future<String> _processImage(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final textRecognizer = TextRecognizer();
      final result = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      return result.text;
    } catch (e) {
      _showError('Image Processing Error: ${e.toString()}');
      return '';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _pickAndProcessFile(bool isPdf) async {
    try {
      setState(() {
        isLoading = true;
        extractedText = '';
        progress = 0;
      });

      final file = isPdf
          ? await FilePicker.platform
              .pickFiles(type: FileType.custom, allowedExtensions: ['pdf'])
          : await ImagePicker().pickImage(source: ImageSource.gallery);

      if (file != null) {
        if (isPdf) {
          await _processPdf(
              File((file as FilePickerResult).files.single.path!));
        } else {
          final text = await _processImage((file as XFile).path);
          setState(() => extractedText = text);
        }
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _shareText() {
    Share.share(extractedText);
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _textEditingController.text = extractedText;
      } else {
        extractedText = _textEditingController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart OCR Scanner'),
        centerTitle: true,
        actions: extractedText.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: _toggleEditing,
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyText,
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareText,
                ),
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => FilePickerMenu(
            onImagePick: () {
              Navigator.pop(context);
              _pickAndProcessFile(false);
            },
            onPdfPick: () {
              Navigator.pop(context);
              _pickAndProcessFile(true);
            },
          ),
        ),
        label: const Text('Scan'),
        icon: const Icon(Icons.document_scanner),
      ),
      body: Stack(
        children: [
          if (extractedText.isNotEmpty) _buildResultView(),
          if (isLoading) _buildProgressOverlay(),
          if (!isLoading && extractedText.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isEditing
                    ? TextField(
                        controller: _textEditingController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          extractedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                    onPressed: _copyText,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    onPressed: _shareText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverlay() {
    return Container(
      color: Theme.of(context).colorScheme.background.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/scanning_animation.json',
              controller: _animationController,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Processing ${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Document Selected',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the + button to start scanning',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
