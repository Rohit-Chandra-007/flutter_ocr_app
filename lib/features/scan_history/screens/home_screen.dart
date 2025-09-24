import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../providers/scan_history_provider.dart';
import '../widgets/scan_history_card.dart';
import '../widgets/empty_history_state.dart';
import '../widgets/search_bar.dart';
import '../../camera/screens/simple_camera_screen.dart';
import '../../document_detail/screens/document_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
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
        pageBuilder: (context, animation, secondaryAnimation) => const SimpleCameraScreen(),
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
        ref.read(scanHistoryProvider.notifier).loadScanHistory();
      }
    });
  }

  void _onSearchChanged(String query) {
    ref.read(scanHistoryProvider.notifier).searchDocuments(query);
  }

  @override
  Widget build(BuildContext context) {
    final scanHistoryAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? CustomSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: () {
                  _searchController.clear();
                  ref.read(scanHistoryProvider.notifier).loadScanHistory();
                },
              )
            : const Text('ScanFlow'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: scanHistoryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (documents) {
          if (documents.isEmpty) {
            return const EmptyHistoryState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(scanHistoryProvider.notifier).loadScanHistory();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return ScanHistoryCard(
                  document: document,
                  onTap: () => _navigateToDocumentDetail(document),
                  onDelete: () => _deleteDocument(document.id),
                ).animate(delay: Duration(milliseconds: index * 50))
                 .fadeIn(duration: 300.ms)
                 .slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: _onFabPressed,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan'),
          heroTag: 'scan_fab',
        ),
      ),
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
                begin: const Offset(0.1, 0.0),
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

  void _deleteDocument(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}