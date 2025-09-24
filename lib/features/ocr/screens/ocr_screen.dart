import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../widgets/file_picker_menu.dart';
import '../widgets/progress_overlay.dart';
import '../widgets/empty_state.dart';
import '../widgets/result_view.dart';
import '../services/ocr_service.dart';
import '../services/pdf_service.dart';
import '../../../core/constants/app_constants.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen>
    with SingleTickerProviderStateMixin {
  String extractedText = '';
  bool isLoading = false;
  double progress = 0;
  late AnimationController _animationController;
  final TextEditingController _textEditingController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.scanningAnimationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textEditingController.dispose();
    OCRService.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessFile(bool isPdf) async {
    try {
      setState(() {
        isLoading = true;
        extractedText = '';
        progress = 0;
      });

      if (isPdf) {
        await _processPDF();
      } else {
        await _processImage();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _processPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final text = await PDFService.extractTextFromPDF(
        file,
        (progress) => setState(() => this.progress = progress),
      );
      setState(() => extractedText = text);
    }
  }

  Future<void> _processImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      final text = await OCRService.extractTextFromImage(image.path);
      setState(() => extractedText = text);
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
          if (extractedText.isNotEmpty)
            ResultView(
              extractedText: extractedText,
              isEditing: _isEditing,
              textEditingController: _textEditingController,
              onToggleEditing: _toggleEditing,
            ),
          if (isLoading)
            ProgressOverlay(
              progress: progress,
              animationController: _animationController,
            ),
          if (!isLoading && extractedText.isEmpty) const EmptyState(),
        ],
      ),
    );
  }
}
