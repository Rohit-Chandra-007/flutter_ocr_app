import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../scan_history/providers/scan_history_provider.dart';
import '../scan_history/screens/home_screen.dart';

class DemoScreen extends ConsumerWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanFlow Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ScanFlow Features Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('View Home Screen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(scanHistoryProvider.notifier).loadScanHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sample data loaded!')),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Load Sample Data'),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Features implemented:\n'
                '✅ Beautiful home screen with document history\n'
                '✅ Sample data loading\n'
                '✅ Search functionality\n'
                '✅ Document detail view\n'
                '✅ Camera screen with OCR\n'
                '✅ Smooth animations\n'
                '✅ Modern Material 3 design\n'
                '✅ Dark/Light theme support',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
