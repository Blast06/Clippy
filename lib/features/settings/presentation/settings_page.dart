import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/controllers/clipboard_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ClipboardController controller = Get.find<ClipboardController>();
  bool _syncEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Backend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: controller.baseUrl.value,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                helperText: 'Configure your backend endpoint for AI processing.',
              ),
              onChanged: controller.updateBaseUrl,
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
      ),
    );
  }
}
