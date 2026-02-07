import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: appProvider.isDarkMode,
              onChanged: appProvider.toggleDarkMode,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Data',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(leading: Icon(Icons.save_alt), title: Text('Export Notes')),
          ),
          const Card(
            child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Clear All Data')),
          ),
          const SizedBox(height: 16),
          Text(
            'Keyboard Shortcuts',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.keyboard),
              title: const Text('Customize Shortcuts'),
              subtitle: const Text('Modify keyboard shortcuts for quick actions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to keyboard shortcuts customization screen
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.keyboard_alt),
              title: const Text('View All Shortcuts'),
              subtitle: const Text('See all available keyboard shortcuts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show keyboard shortcuts reference dialog
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Restore default keyboard shortcuts'),
              onTap: () {
                // TODO: Show confirmation dialog and reset shortcuts
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('Version 1.0.0')),
          const SizedBox(height: 4),
          const Center(child: Text('© 2026 Noteable App')),
        ],
      ),
    );
  }
}
