import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/providers.dart';
import '../domain/clipboard_item.dart';

class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({super.key, required this.item});

  final ClipboardItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analyzerProvider(item.content));
    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.content,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                Chip(label: Text(item.type.name.toUpperCase())),
                if (item.isFavorite)
                  const Chip(label: Text('Favorite')),
                ...item.tags.map((tag) => Chip(label: Text(tag))),
              ],
            ),
            const SizedBox(height: 24),
            Text('AI Analysis (via backend)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            analysis.when(
              data: (result) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(result.title,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(result.summary),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        result.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Failed to fetch analysis: $error'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showTransformSheet(context),
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Send to backend for transform'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransformSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text('Transform via backend'),
            SizedBox(height: 8),
            Text('POST /clipboard/transform'),
            SizedBox(height: 16),
            Text(
              'Hook this sheet to send the clipboard content to your backend for '
              'summarization, cleanup, translation, or rewriting.',
            ),
          ],
        ),
      ),
    );
  }
}
