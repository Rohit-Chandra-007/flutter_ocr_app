import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow/core/models/scan_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../../scan_history/providers/scan_history_provider.dart';
import '../../settings/widgets/theme_toggle_button.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final ScanDocument document;

  const DocumentDetailScreen({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _textController =
        TextEditingController(text: widget.document.extractedText);

    _titleController.addListener(_onTextChanged);
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasUnsavedChanges) return;

    try {
      widget.document.updateTitle(_titleController.text);
      widget.document.updateText(_textController.text);

      await ref
          .read(scanHistoryProvider.notifier)
          .updateScanDocument(widget.document);

      setState(() {
        _hasUnsavedChanges = false;
        _isEditing = false;
      });

      _showSuccess('Document updated successfully');
    } catch (e) {
      _showError('Failed to save changes: ${e.toString()}');
    }
  }

  void _discardChanges() {
    setState(() {
      _titleController.text = widget.document.title;
      _textController.text = widget.document.extractedText;
      _hasUnsavedChanges = false;
      _isEditing = false;
    });
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.document.extractedText));
    _showSuccess('Text copied to clipboard');
  }

  void _shareText() {
    Share.share(
      widget.document.extractedText,
      subject: widget.document.title,
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content:
              const Text('You have unsaved changes. Do you want to save them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                _saveChanges();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  void _showPageText(ScanPage page) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.text_fields, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Page ${page.pageNumber} Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Text content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    page.extractedText.isEmpty
                        ? 'No text found on this page'
                        : page.extractedText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: page.extractedText));
                          Navigator.pop(context);
                          _showSuccess('Page ${page.pageNumber} text copied');
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Text'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Share.share(
                            page.extractedText,
                            subject:
                                '${widget.document.title} - Page ${page.pageNumber}',
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageThumbnail(ScanPage page) {
    return GestureDetector(
      onTap: () => _showPageText(page),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.file(
                File(page.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.text_fields,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Page ${page.pageNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isEditing
              ? TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Document title',
                  ),
                )
              : Text(
                  widget.document.title,
                  overflow: TextOverflow.ellipsis,
                ),
          actions: [
            if (_isEditing) ...[
              TextButton(
                onPressed: _discardChanges,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _saveChanges,
                child: const Text('Save'),
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'copy':
                      _copyText();
                      break;
                    case 'share':
                      _shareText();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copy Text'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            // Document info
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    'Created: ${dateFormat.format(widget.document.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (widget.document.pageCount > 1)
                    Chip(
                      label: Text('${widget.document.pageCount} pages'),
                      backgroundColor:
                          AppTheme.primaryBlue.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Pages content
            Expanded(
              child: widget.document.pages.isEmpty
                  ? const Center(
                      child: Text('No pages available'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacing12,
                        mainAxisSpacing: AppTheme.spacing12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: widget.document.pages.length,
                      itemBuilder: (context, index) {
                        final page = widget.document.pages[index];
                        return _buildPageThumbnail(page);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
