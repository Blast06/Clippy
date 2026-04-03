import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../clipboard/presentation/controllers/clipboard_controller.dart';
import '../../history/presentation/item_detail_page.dart';
import '../../shared/widgets/clipboard_item_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClipboardController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Obx(() {
        final favorites = controller.favorites;

        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favorites.isEmpty) {
          return const Center(child: Text('No favorites yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return ClipboardItemCard(
              item: item,
              onTap: (tapped) => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ItemDetailPage(item: tapped),
                ),
              ),
              onToggleFavorite: (tapped) async {
                await controller.toggleFavorite(tapped.id);
              },
              onCopy: (tapped) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied: ${tapped.content}')),
                );
              },
            );
          },
        );
      }),
    );
  }
}
