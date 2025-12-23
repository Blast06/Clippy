import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/providers.dart';
import '../../shared/widgets/clipboard_item_card.dart';
import '../../history/presentation/item_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                  ref.invalidate(favoritesProvider);
                  ref.invalidate(clipboardItemsProvider);
                },
                onCopy: (tapped) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied: ${tapped.content}')),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
