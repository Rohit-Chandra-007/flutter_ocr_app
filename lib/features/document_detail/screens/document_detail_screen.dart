import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../../scan_history/providers/scan_history_provider.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final ScanDocument document;

  const DocumentDetailScreen({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late TabController _tabController;
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _textController = TextEditingController(text: widget.document.extractedText);
    _tabController = TabController(length: 2, vsync: this);
    
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
      
      await ref.read(scanHistoryProvider.notifier).updateScanDocument(widget.document);
      
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
          content: const Text('You have unsaved changes. Do you want to save them?'),
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

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _tabController.dispose();
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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Text', icon: Icon(Icons.text_fields)),
              Tab(text: 'Images', icon: Icon(Icons.image)),
            ],
          ),
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
                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Text tab
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: _isEditing
                        ? TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter text...',
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        : SingleChildScrollView(
                            child: SelectableText(
                              widget.document.extractedText.isEmpty
                                  ? 'No text extracted'
                                  : widget.document.extractedText,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                  ),
                  
                  // Images tab
                  widget.document.imagePaths.isEmpty
                      ? const Center(
                          child: Text('No images available'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppTheme.spacing12,
                            mainAxisSpacing: AppTheme.spacing12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: widget.document.imagePaths.length,
                          itemBuilder: (context, index) {
                            final imagePath = widget.document.imagePaths[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Image.file(
                                      File(imagePath),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Page ${index + 1}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}