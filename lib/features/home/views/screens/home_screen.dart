import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/scan_document.dart';
import '../../../camera/screens/scan_options_screen.dart';
import '../../../document_detail/screens/document_detail_screen.dart';
import '../../../settings/views/screens/settings_screen.dart';
import '../../viewmodels/scan_history_provider.dart';
import '../widgets/empty_history_state.dart';
import '../widgets/scan_history_card.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ScanOptionsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.invalidate(scanHistoryProvider);
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      ref.invalidate(scanHistoryProvider);
    } else {
      ref.read(scanHistoryProvider.notifier).searchDocuments(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanHistoryAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _isSearching
            ? CustomSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: () {
                  _searchController.clear();
                  ref.invalidate(scanHistoryProvider);
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ScanFlow',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Your documents',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: scanHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
        data: (documents) {
          if (documents.isEmpty) {
            return const EmptyHistoryState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final document = documents[index];
              return ScanHistoryCard(
                document: document,
                onTap: () => _navigateToDocumentDetail(document),
                onDelete: () => _deleteDocument(document.id),
              )
                  .animate(delay: Duration(milliseconds: index * 50))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
            },
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(scanHistoryProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _onFabPressed,
      icon: const Icon(Icons.document_scanner_rounded),
      label: const Text('Scan'),
      heroTag: 'scan_fab',
      elevation: 4,
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
    );
  }

  void _navigateToDocumentDetail(ScanDocument document) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DocumentDetailScreen(document: document),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _deleteDocument(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Document'),
        content: const Text(
            'Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(scanHistoryProvider.notifier).deleteScanDocument(id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
