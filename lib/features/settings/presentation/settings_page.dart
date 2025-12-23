import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _syncEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final baseUrl = ref.watch(baseUrlProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Backend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: baseUrl,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              helperText: 'Configure your backend endpoint for AI processing.',
            ),
            onChanged: (value) => ref.read(baseUrlProvider.notifier).state = value,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _syncEnabled,
            title: const Text('Enable cloud sync'),
            subtitle: const Text('Opt-in synchronization across devices.'),
            onChanged: (value) => setState(() => _syncEnabled = value),
          ),
          SwitchListTile(
            value: _biometricEnabled,
            title: const Text('Biometric / PIN lock'),
            subtitle: const Text('Gate clipboard access behind authentication.'),
            onChanged: (value) => setState(() => _biometricEnabled = value),
          ),
          const SizedBox(height: 16),
          const Text('Privacy'),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Exclude sensitive apps'),
            subtitle: Text('Wire this to your platform channel implementation.'),
          ),
          const ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Clear history'),
            subtitle: Text('Provide a confirmation dialog to purge local data.'),
          ),
        ],
      ),
    );
  }
}
