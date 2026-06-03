import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../shared/widgets/clipboard_item_card.dart';
import '../../shared/widgets/empty_state.dart';
import 'controllers/favorites_controller.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Obx(() {
        final favorites = controller.favorites;

        if (controller.loading.value) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading favorites...'),
              ],
            ),
          );
        }

        if (favorites.isEmpty) {
          return const EmptyState(
            icon: Icons.star_border,
            title: 'No favorites yet',
            message:
                'Star important clipboard items from History so they are easy to find later.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return ClipboardItemCard(
              item: item,
              onTap: (tapped) => Get.toNamed(
                AppRoutes.itemDetail,
                arguments: tapped,
              ),
              onToggleFavorite: (tapped) async {
                await controller.toggleFavorite(tapped.id);
              },
              onCopy: (tapped) async {
                await Clipboard.setData(ClipboardData(text: tapped.content));
                if (!context.mounted) {
                  return;
                }
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
