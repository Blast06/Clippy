import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../clipboard/presentation/controllers/clipboard_controller.dart';
import '../../shared/widgets/clipboard_item_card.dart';
import '../domain/clipboard_item.dart';
import 'item_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ClipboardController controller = Get.find<ClipboardController>();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard History'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await controller
                  .addItem('New sample snippet at ${DateTime.now()}');
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
                      onTap: (tapped) => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ItemDetailPage(item: tapped),
                        ),
                      ),
                      onToggleFavorite: (tapped) async {
                        await controller.toggleFavorite(tapped.id);
                      },
                      onCopy: (tapped) async {
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
}
