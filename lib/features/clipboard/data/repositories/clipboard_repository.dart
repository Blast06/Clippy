import 'dart:async';
import 'dart:convert';

import '../../../history/domain/analysis_result.dart';
import '../../../history/domain/clipboard_item.dart';
import '../../../history/domain/folder.dart';
import '../database/clipboard_database_schema.dart';
import '../services/clipboard_api_service.dart';
import '../services/clipboard_database_service.dart';

class ClipboardRepository {
  ClipboardRepository(this._databaseService, this._apiService);

  final ClipboardDatabaseService _databaseService;
  final ClipboardApiService _apiService;

  Future<List<ClipboardItem>> fetchItems() async {
    final List<Map<String, Object?>> rows = await _databaseService.fetchItems();
    return rows.map(_mapItem).toList(growable: false);
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
    await _databaseService.insertItem(_itemToMap(item));
  }

  Future<void> toggleFavorite(String id) async {
    final Map<String, Object?>? itemRow =
        await _databaseService.fetchItemById(id);
    if (itemRow == null) {
      return;
    }

    final ClipboardItem item = _mapItem(itemRow);
    await _databaseService.updateItemFavorite(
      id: id,
      isFavorite: !item.isFavorite,
    );
  }

  Future<List<ClipboardItem>> fetchFavorites() async {
    return (await fetchItems()).where((item) => item.isFavorite).toList();
  }

  Future<List<ClipboardFolder>> fetchFolders() async {
    final List<Map<String, Object?>> rows =
        await _databaseService.fetchFolders();
    return rows.map(_mapFolder).toList(growable: false);
  }

  Future<void> createFolder({
    required String id,
    required String name,
    String? description,
  }) async {
    await _databaseService.upsertFolder(
      <String, Object?>{
        ClipboardDatabaseSchema.folderId: id,
        ClipboardDatabaseSchema.folderName: name,
        ClipboardDatabaseSchema.folderDescription: description,
      },
    );
  }

  Future<AnalysisResult> analyze(String text) async {
    return _apiService.analyze(text);
  }

  void updateBaseUrl(String value) {
    _apiService.updateBaseUrl(value);
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

  ClipboardItem _mapItem(Map<String, Object?> row) {
    return ClipboardItem.withId(
      id: row[ClipboardDatabaseSchema.itemId]! as String,
      content: row[ClipboardDatabaseSchema.itemContent]! as String,
      createdAt: DateTime.parse(
        row[ClipboardDatabaseSchema.itemCreatedAt]! as String,
      ),
      type: ClipboardItemType.values.firstWhere(
        (ClipboardItemType itemType) =>
            itemType.name == row[ClipboardDatabaseSchema.itemType],
        orElse: () => ClipboardItemType.unknown,
      ),
      isFavorite: (row[ClipboardDatabaseSchema.itemIsFavorite]! as int) == 1,
      folderId: row[ClipboardDatabaseSchema.itemFolderId] as String?,
      tags: (jsonDecode(row[ClipboardDatabaseSchema.itemTags]! as String)
              as List<dynamic>)
          .map((dynamic tag) => tag.toString())
          .toList(growable: false),
    );
  }

  Map<String, Object?> _itemToMap(ClipboardItem item) {
    return <String, Object?>{
      ClipboardDatabaseSchema.itemId: item.id,
      ClipboardDatabaseSchema.itemContent: item.content,
      ClipboardDatabaseSchema.itemCreatedAt: item.createdAt.toIso8601String(),
      ClipboardDatabaseSchema.itemType: item.type.name,
      ClipboardDatabaseSchema.itemIsFavorite: item.isFavorite ? 1 : 0,
      ClipboardDatabaseSchema.itemFolderId: item.folderId,
      ClipboardDatabaseSchema.itemTags: jsonEncode(item.tags),
    };
  }

  ClipboardFolder _mapFolder(Map<String, Object?> row) {
    return ClipboardFolder(
      id: row[ClipboardDatabaseSchema.folderId]! as String,
      name: row[ClipboardDatabaseSchema.folderName]! as String,
      description: row[ClipboardDatabaseSchema.folderDescription] as String?,
    );
  }
}
