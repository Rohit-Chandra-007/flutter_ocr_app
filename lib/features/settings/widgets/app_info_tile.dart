import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/settings_viewmodel.dart';

class AppInfoTile extends ConsumerWidget {
  const AppInfoTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final appInfo = viewModel.appInfo;

    return ListTile(
      leading: const Icon(Icons.document_scanner, color: AppTheme.primaryBlue),
      title: Text(appInfo.appName),
      subtitle: Text('Version ${appInfo.version}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(context, appInfo),
    );
  }

  void _showAboutDialog(BuildContext context, appInfo) {
    showAboutDialog(
      context: context,
      applicationName: appInfo.appName,
      applicationVersion: appInfo.version,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.document_scanner,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        Text(appInfo.description),
        const SizedBox(height: 16),
        Text(appInfo.tagline),
      ],
    );
  }
}
