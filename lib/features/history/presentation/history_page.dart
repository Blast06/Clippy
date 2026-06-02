import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../clipboard/presentation/controllers/clipboard_state_controller.dart';
import '../../shared/widgets/clipboard_item_card.dart';
import '../domain/clipboard_item.dart';
import 'controllers/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController controller = Get.find<HistoryController>();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard History'),
        actions: <Widget>[
          Obx(
            () => IconButton(
              tooltip: 'Read clipboard',
              icon: controller.readingClipboard.value
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.content_paste_search),
              onPressed: controller.readingClipboard.value
                  ? null
                  : () => _readClipboard(context),
            ),
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
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<ClipboardItem> items = _query.isEmpty
                    ? controller.items
                    : controller.search(_query);

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                        'No clipboard items yet. Copy something to get started!'),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ClipboardItemCard(
                      item: item,
                      onTap: (tapped) =>
                          Get.toNamed(AppRoutes.itemDetail, arguments: tapped),
                      onToggleFavorite: (tapped) async {
                        await controller.toggleFavorite(tapped.id);
                      },
                      onCopy: (tapped) async {
                        await Clipboard.setData(
                          ClipboardData(text: tapped.content),
                        );
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _readClipboard(BuildContext context) async {
    final ClipboardReadResult result = await controller.readSystemClipboard();
    if (!context.mounted) {
      return;
    }

    final String message = switch (result) {
      ClipboardReadResult.added => 'Clipboard saved to history',
      ClipboardReadResult.duplicate => 'Clipboard item already exists',
      ClipboardReadResult.empty => 'Clipboard is empty',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
