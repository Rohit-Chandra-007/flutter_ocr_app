import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';

class ResultView extends StatelessWidget {
  final String extractedText;
  final bool isEditing;
  final TextEditingController textEditingController;
  final VoidCallback onToggleEditing;

  const ResultView({
    super.key,
    required this.extractedText,
    required this.isEditing,
    required this.textEditingController,
    required this.onToggleEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: isEditing
                    ? TextField(
                        controller: textEditingController,
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
                    onPressed: () => _copyText(context),
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

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppConstants.textCopiedMessage)),
    );
  }

  void _shareText() {
    Share.share(extractedText);
  }
}