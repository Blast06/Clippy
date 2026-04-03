import 'dart:async';

import '../../../history/domain/analysis_result.dart';
import '../../../history/domain/clipboard_item.dart';
import '../../../history/domain/folder.dart';
import '../services/clipboard_service.dart';

class ClipboardRepository {
  ClipboardRepository(this._service) {
    _seedData();
  }

  final ClipboardService _service;
  final List<ClipboardItem> _items = <ClipboardItem>[];
  final List<ClipboardFolder> _folders = <ClipboardFolder>[];

  Future<List<ClipboardItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<ClipboardItem>.unmodifiable(_items);
  }

  Future<List<ClipboardItem>> searchItems(String query) async {
    final lower = query.toLowerCase();
    return (await fetchItems())
        .where(
          (item) =>
              item.content.toLowerCase().contains(lower) ||
              item.tags.any((tag) => tag.toLowerCase().contains(lower)),
        )
        .toList();
  }

  Future<void> addItem(String content, {ClipboardItemType? type}) async {
    final inferred = type ?? _inferType(content);
    final item = ClipboardItem(
      content: content,
      createdAt: DateTime.now(),
      type: inferred,
    );
    _items.insert(0, item);
  }

  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final item = _items[index];
    _items[index] = item.copyWith(isFavorite: !item.isFavorite);
  }

  Future<List<ClipboardItem>> fetchFavorites() async {
    return (await fetchItems()).where((item) => item.isFavorite).toList();
  }

  Future<List<ClipboardFolder>> fetchFolders() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<ClipboardFolder>.unmodifiable(_folders);
  }

  Future<AnalysisResult> analyze(String text) async {
    return _service.analyze(text);
  }

  void updateBaseUrl(String value) {
    _service.updateBaseUrl(value);
  }

  ClipboardItemType _inferType(String content) {
    final uri = Uri.tryParse(content);
    if (uri != null && uri.hasAbsolutePath) {
      return ClipboardItemType.url;
    }

    final number = num.tryParse(content);
    if (number != null) {
      return ClipboardItemType.number;
    }

    return ClipboardItemType.text;
  }

  void _seedData() {
    _folders.addAll(
      <ClipboardFolder>[
        const ClipboardFolder(id: 'general', name: 'General'),
        const ClipboardFolder(id: 'work', name: 'Work'),
        const ClipboardFolder(id: 'ideas', name: 'Ideas'),
      ],
    );

    final now = DateTime.now();
    _items.addAll(
      <ClipboardItem>[
        ClipboardItem.withId(
          id: '1',
          content: 'https://docs.mybackend.dev/api',
          createdAt: now.subtract(const Duration(minutes: 10)),
          type: ClipboardItemType.url,
          isFavorite: true,
          tags: const <String>['api', 'docs'],
        ),
        ClipboardItem.withId(
          id: '2',
          content: 'Next stand-up at 9:30 AM tomorrow.',
          createdAt: now.subtract(const Duration(hours: 2)),
          type: ClipboardItemType.text,
          isFavorite: false,
          folderId: 'work',
        ),
        ClipboardItem.withId(
          id: '3',
          content: '443-221',
          createdAt: now.subtract(const Duration(days: 1)),
          type: ClipboardItemType.number,
          isFavorite: false,
        ),
      ],
    );
  }
}
