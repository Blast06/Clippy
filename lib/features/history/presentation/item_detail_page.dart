import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/ai_action_result.dart';
import '../domain/clipboard_item.dart';
import 'controllers/ai_controller.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.item});

  factory ItemDetailPage.fromRoute() {
    final ClipboardItem item = Get.arguments as ClipboardItem;
    return ItemDetailPage(item: item);
  }

  final ClipboardItem item;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final AiController controller = Get.find<AiController>();
  late ClipboardItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    controller.clearMessages();
    controller.loadResults(_item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            _item.content,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              Chip(label: Text(_item.type.name.toUpperCase())),
              if (_item.isFavorite) const Chip(label: Text('Favorite')),
              ..._item.tags.map((tag) => Chip(label: Text(tag))),
            ],
          ),
          const SizedBox(height: 24),
          Text('AI Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(
            () => _BackendStatusBanner(
              canUseBackend: controller.canUseBackend,
              errorMessage: controller.errorMessage.value,
              successMessage: controller.successMessage.value,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AiActionType.values
                  .map(
                    (action) => _ActionButton(
                      action: action,
                      runningAction: controller.runningAction.value,
                      enabled: controller.canUseBackend,
                      onPressed: () => controller.runAction(
                        item: _item,
                        action: action,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 24),
          Text('Saved Results', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.results.isEmpty) {
              return const Text(
                'Run an AI action to save a backend result here.',
              );
            }

            return Column(
              children: controller.results
                  .map(
                    (result) => _AiResultCard(
                      result: result,
                      onCopy: () => _copyResult(context, result),
                      onSaveAsSnippet: () => _saveAsSnippet(context, result),
                      onReplaceOriginal: () =>
                          _replaceOriginal(context, result),
                    ),
                  )
                  .toList(growable: false),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _copyResult(
    BuildContext context,
    AiActionResult result,
  ) async {
    await controller.copyResult(result);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI result copied')),
    );
  }

  Future<void> _saveAsSnippet(
    BuildContext context,
    AiActionResult result,
  ) async {
    await controller.saveAsSnippet(result);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI result saved as snippet')),
    );
  }

  Future<void> _replaceOriginal(
    BuildContext context,
    AiActionResult result,
  ) async {
    await controller.replaceOriginal(item: _item, result: result);
    setState(() => _item = _item.copyWith(content: result.output));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Original clipboard item replaced')),
    );
  }
}

class _BackendStatusBanner extends StatelessWidget {
  const _BackendStatusBanner({
    required this.canUseBackend,
    required this.errorMessage,
    required this.successMessage,
  });

  final bool canUseBackend;
  final String errorMessage;
  final String successMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return _StatusCard(
        icon: Icons.error_outline,
        message: errorMessage,
        color: Theme.of(context).colorScheme.errorContainer,
      );
    }

    if (successMessage.isNotEmpty) {
      return _StatusCard(
        icon: Icons.check_circle_outline,
        message: successMessage,
        color: Theme.of(context).colorScheme.primaryContainer,
      );
    }

    if (!canUseBackend) {
      return _StatusCard(
        icon: Icons.cloud_off_outlined,
        message:
            'Backend is disabled. Enable it in Settings to run AI actions.',
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: ListTile(
        leading: Icon(icon),
        title: Text(message),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.runningAction,
    required this.enabled,
    required this.onPressed,
  });

  final AiActionType action;
  final AiActionType? runningAction;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isRunning = runningAction == action;
    final bool anyRunning = runningAction != null;

    return FilledButton.tonalIcon(
      onPressed: enabled && !anyRunning ? onPressed : null,
      icon: isRunning
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_fix_high),
      label: Text(action.label),
    );
  }
}

class _AiResultCard extends StatelessWidget {
  const _AiResultCard({
    required this.result,
    required this.onCopy,
    required this.onSaveAsSnippet,
    required this.onReplaceOriginal,
  });

  final AiActionResult result;
  final VoidCallback onCopy;
  final VoidCallback onSaveAsSnippet;
  final VoidCallback onReplaceOriginal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    result.action.label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                PopupMenuButton<_ResultAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _ResultAction.copy:
                        onCopy();
                      case _ResultAction.saveAsSnippet:
                        onSaveAsSnippet();
                      case _ResultAction.replaceOriginal:
                        onReplaceOriginal();
                    }
                  },
                  itemBuilder: (context) =>
                      const <PopupMenuEntry<_ResultAction>>[
                    PopupMenuItem<_ResultAction>(
                      value: _ResultAction.copy,
                      child: Text('Copy result'),
                    ),
                    PopupMenuItem<_ResultAction>(
                      value: _ResultAction.saveAsSnippet,
                      child: Text('Save as snippet'),
                    ),
                    PopupMenuItem<_ResultAction>(
                      value: _ResultAction.replaceOriginal,
                      child: Text('Replace original'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(result.output),
          ],
        ),
      ),
    );
  }
}

enum _ResultAction { copy, saveAsSnippet, replaceOriginal }
