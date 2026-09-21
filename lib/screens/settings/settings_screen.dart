import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Personal Data?'),
        content: const Text(
          'This will permanently delete your tasks, knowledge, reflections, decisions, ideas and focus history from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await StorageService.clearAllPersonalData();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All personal data has been cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _section(
            context,
            title: 'App',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Profile'),
                subtitle: const Text('Shartendu'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About Shartendu OS'),
                subtitle: const Text(
                  'Personal development operating system',
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            title: 'Data',
            children: [
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Local Storage'),
                subtitle: const Text(
                  'Your current data is stored locally on this device.',
                ),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Clear All Personal Data',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Permanently remove all app data from this device.',
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () => _clearData(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            context,
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text('Shartendu OS'),
                subtitle: const Text('Version 1.0.0'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
