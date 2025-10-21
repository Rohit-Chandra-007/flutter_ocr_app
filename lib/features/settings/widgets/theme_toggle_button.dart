import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'theme_mode_tile.dart';

class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(themeViewModelProvider.notifier);
    final currentOption = viewModel.currentOption;

    if (showLabel) {
      return ListTile(
        leading: Icon(
          currentOption.icon,
          size: iconSize,
          color: AppTheme.primaryBlue,
        ),
        title: Text(currentOption.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeDialog(context, ref),
      );
    }

    return IconButton(
      icon: Icon(currentOption.icon, size: iconSize),
      onPressed: () => _showThemeDialog(context, ref),
      tooltip: 'Change theme',
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(themeViewModelProvider.notifier);
    final options = viewModel.availableOptions;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ThemeModeTile(
              mode: option.mode,
              isSelected: viewModel.isSelected(option.mode),
              onTap: () {
                viewModel.setThemeMode(option.mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class SimpleThemeToggle extends ConsumerWidget {
  final double iconSize;

  const SimpleThemeToggle({
    super.key,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(themeViewModelProvider.notifier);
    final currentOption = viewModel.currentOption;

    return IconButton(
      icon: Icon(currentOption.icon, size: iconSize),
      onPressed: () => viewModel.toggleTheme(),
      tooltip: 'Toggle theme',
    );
  }
}
