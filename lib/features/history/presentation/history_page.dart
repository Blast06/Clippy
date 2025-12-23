import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/providers.dart';
import '../../shared/widgets/clipboard_item_card.dart';
import '../domain/clipboard_item.dart';
import 'item_detail_page.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(
      _query.isEmpty
          ? clipboardItemsProvider
          : clipboardItemsProvider
              .select((value) => value.whenData(
                    (items) => items
                        .where(
                          (item) => item.content
                              .toLowerCase()
                              .contains(_query.toLowerCase()),
                        )
                        .toList(),
                  )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard History'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final repo = ref.read(clipboardRepositoryProvider);
              await repo.addItem('New sample snippet at ${DateTime.now()}');
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search clipboard…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: asyncItems.when(
                data: (items) => _HistoryList(items: items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.items});

  final List<ClipboardItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No clipboard items yet. Copy something to get started!'),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ClipboardItemCard(
          item: item,
          onTap: (tapped) => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ItemDetailPage(item: tapped),
            ),
          ),
          onToggleFavorite: (tapped) async {
            final repo = ref.read(clipboardRepositoryProvider);
            await repo.toggleFavorite(tapped.id);
            ref.invalidate(clipboardItemsProvider);
            ref.invalidate(favoritesProvider);
          },
          onCopy: (tapped) async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: ${tapped.content}')),
            );
          },
        );
      },
    );
  }
}
