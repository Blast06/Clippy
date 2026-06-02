import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController controller = Get.find<SettingsController>();
  late final TextEditingController _baseUrlController;
  late final Worker _baseUrlWorker;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: controller.baseUrl.value);
    _baseUrlWorker = ever<String>(controller.baseUrl, (value) {
      if (_baseUrlController.text == value) {
        return;
      }
      _baseUrlController.text = value;
    });
  }

  @override
  void dispose() {
    _baseUrlWorker.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

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
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                helperText:
                    'Configure your backend endpoint for AI processing.',
              ),
              enabled: !controller.localOnlyMode.value,
              onChanged: (value) => controller.updateBaseUrl(value),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: controller.backendEnabled.value,
              title: const Text('Backend enabled'),
              subtitle: const Text('Allow backend calls for AI features.'),
              onChanged: (value) => controller.updateBackendEnabled(value),
            ),
            SwitchListTile(
              value: controller.localOnlyMode.value,
              title: const Text('Local-only mode'),
              subtitle:
                  const Text('Keep clipboard history and analysis local.'),
              onChanged: (value) => controller.updateLocalOnlyMode(value),
            ),
            const SizedBox(height: 24),
            Text('Security', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const SwitchListTile(
              value: false,
              title: Text('Biometric lock'),
              subtitle: Text('Placeholder only. Not implemented yet.'),
              onChanged: null,
            ),
            const SwitchListTile(
              value: false,
              title: Text('PIN lock'),
              subtitle: Text('Placeholder only. Not implemented yet.'),
              onChanged: null,
            ),
            const SizedBox(height: 24),
            Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
            const ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Exclude sensitive apps'),
              subtitle: Text('Placeholder for future app exclusion rules.'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear history'),
              onPressed: () => _confirmClearHistory(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Clear clipboard history?'),
            content: const Text(
              'This removes all saved clipboard items from this device.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await controller.clearHistory();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clipboard history cleared')),
    );
  }
}
