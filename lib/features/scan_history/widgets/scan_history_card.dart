import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';

class ScanHistoryCard extends StatefulWidget {
  final ScanDocument document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScanHistoryCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<ScanHistoryCard> createState() => _ScanHistoryCardState();
}

class _ScanHistoryCardState extends State<ScanHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: _isPressed
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : theme.dividerColor,
                width: 1,
              ),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document thumbnail
                  _buildThumbnail(),
                  const SizedBox(width: AppTheme.spacing16),
                  
                  // Document info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.document.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        
                        // Preview text
                        Text(
                          widget.document.previewText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        
                        // Date and page count
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: AppTheme.spacing4),
                            Text(
                              dateFormat.format(widget.document.createdAt),
                              style: theme.textTheme.bodySmall,
                            ),
                            if (widget.document.pageCount > 1) ...[
                              const SizedBox(width: AppTheme.spacing12),
                              Icon(
                                Icons.description,
                                size: 14,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: AppTheme.spacing4),
                              Text(
                                '${widget.document.pageCount} pages',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          widget.onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: widget.document.imagePaths.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 1),
              child: Image.file(
                File(widget.document.imagePaths.first),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultThumbnail(),
              ),
            )
          : _buildDefaultThumbnail(),
    );
  }

  Widget _buildDefaultThumbnail() {
    return const Icon(
      Icons.description,
      color: AppTheme.primaryBlue,
      size: 32,
    );
  }
}