import 'dart:async';
import 'dart:convert';

import '../../../../core/api/api_exception.dart';
import '../../../history/domain/ai_action_result.dart';
import '../../../history/domain/analysis_result.dart';
import '../../../history/domain/clipboard_item.dart';
import '../../../history/domain/folder.dart';
import '../database/clipboard_database_schema.dart';
import '../dtos/clipboard_api_dtos.dart';
import '../services/clipboard_api_service.dart';
import '../services/clipboard_database_service.dart';

class ClipboardRepository {
  ClipboardRepository(this._databaseService, this._apiService);

  static const String backendEnabledKey = 'backend_enabled';
  static const String localOnlyModeKey = 'local_only_mode';
  static const String backendBaseUrlKey = 'backend_base_url';

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

  Future<ClipboardItem?> addItem(String content,
      {ClipboardItemType? type}) async {
    final normalizedContent = content.trim();
    if (normalizedContent.isEmpty) {
      return null;
    }

    final inferred = type ?? _inferType(normalizedContent);
    final item = ClipboardItem(
      content: normalizedContent,
      createdAt: DateTime.now(),
      type: inferred,
    );
    await _databaseService.insertItem(_itemToMap(item));
    return item;
  }

  Future<void> replaceItemContent({
    required String id,
    required String content,
  }) async {
    final normalizedContent = content.trim();
    if (normalizedContent.isEmpty) {
      return;
    }

    await _databaseService.updateItemContent(
      id: id,
      content: normalizedContent,
      type: _inferType(normalizedContent).name,
    );
  }

  Future<void> clearHistory() async {
    await _databaseService.clearItems();
  }

  Future<bool> containsContent(String content) async {
    final normalizedContent = _normalizeForDuplicate(content);
    if (normalizedContent.isEmpty) {
      return false;
    }

    return (await fetchItems()).any(
      (item) => _normalizeForDuplicate(item.content) == normalizedContent,
    );
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
    try {
      return await _apiService.analyze(text);
    } on ApiException catch (error) {
      return AnalysisResult(
        title: 'Backend unavailable',
        summary: error.message,
        tags: const <String>['backend-error'],
      );
    }
  }

  Future<ClipboardTransformResponseDto> transform({
    required String text,
    required String action,
    required String instruction,
  }) {
    return _apiService.transform(
      text: text,
      action: action,
      instruction: instruction,
    );
  }

  Future<ClipboardClassifyResponseDto> classify(String text) {
    return _apiService.classify(text);
  }

  Future<AiActionResult> runAiAction({
    required ClipboardItem item,
    required AiActionType action,
  }) async {
    final String output = switch (action) {
      AiActionType.classify => _formatClassification(
          await classify(item.content),
        ),
      _ => (await transform(
          text: item.content,
          action: action.key,
          instruction: action.instruction,
        ))
            .text,
    };

    if (output.trim().isEmpty) {
      throw const ApiException(
        type: ApiExceptionType.decoding,
        message: 'Backend returned an empty result.',
      );
    }

    final result = AiActionResult(
      itemId: item.id,
      action: action,
      input: item.content,
      output: output.trim(),
      createdAt: DateTime.now(),
    );
    await _databaseService.insertAiActionResult(_aiActionResultToMap(result));
    return result;
  }

  Future<List<AiActionResult>> fetchAiActionResults(String itemId) async {
    final List<Map<String, Object?>> rows =
        await _databaseService.fetchAiActionResults(itemId);
    return rows.map(_mapAiActionResult).toList(growable: false);
  }

  Future<String?> fetchSetting(String key) {
    return _databaseService.fetchSetting(key);
  }

  Future<void> saveSetting(String key, String value) {
    return _databaseService.upsertSetting(key: key, value: value);
  }

  void updateBaseUrl(String value) {
    _apiService.updateBaseUrl(value);
  }

  ClipboardItemType _inferType(String content) {
    final trimmed = content.trim();

    final emailPattern = RegExp(
      r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
      caseSensitive: false,
    );
    if (emailPattern.hasMatch(trimmed)) {
      return ClipboardItemType.email;
    }

    if (_isUrl(trimmed)) {
      return ClipboardItemType.url;
    }

    final number = num.tryParse(trimmed.replaceAll(',', ''));
    if (number != null && _isPlainNumber(trimmed)) {
      return ClipboardItemType.number;
    }

    if (_isPhoneNumber(trimmed)) {
      return ClipboardItemType.phone;
    }

    return ClipboardItemType.text;
  }

  bool _isUrl(String content) {
    final uri = Uri.tryParse(content);
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return true;
    }

    return RegExp(
      r'^(www\.)[A-Z0-9.-]+\.[A-Z]{2,}([/?#].*)?$',
      caseSensitive: false,
    ).hasMatch(content);
  }

  bool _isPhoneNumber(String content) {
    final phonePattern = RegExp(r'^\+?[\d\s().-]{7,}$');
    final digitCount = RegExp(r'\d').allMatches(content).length;
    return phonePattern.hasMatch(content) && digitCount >= 7;
  }

  bool _isPlainNumber(String content) {
    return RegExp(r'^-?(\d+|\d{1,3}(,\d{3})+)(\.\d+)?$').hasMatch(content);
  }

  String _normalizeForDuplicate(String content) {
    return content.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
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

  AiActionResult _mapAiActionResult(Map<String, Object?> row) {
    return AiActionResult.withId(
      id: row[ClipboardDatabaseSchema.aiResultId]! as String,
      itemId: row[ClipboardDatabaseSchema.aiResultItemId]! as String,
      action: AiActionType.values.firstWhere(
        (AiActionType action) =>
            action.key == row[ClipboardDatabaseSchema.aiResultAction],
        orElse: () => AiActionType.summarize,
      ),
      input: row[ClipboardDatabaseSchema.aiResultInput]! as String,
      output: row[ClipboardDatabaseSchema.aiResultOutput]! as String,
      createdAt: DateTime.parse(
        row[ClipboardDatabaseSchema.aiResultCreatedAt]! as String,
      ),
    );
  }

  Map<String, Object?> _aiActionResultToMap(AiActionResult result) {
    return <String, Object?>{
      ClipboardDatabaseSchema.aiResultId: result.id,
      ClipboardDatabaseSchema.aiResultItemId: result.itemId,
      ClipboardDatabaseSchema.aiResultAction: result.action.key,
      ClipboardDatabaseSchema.aiResultInput: result.input,
      ClipboardDatabaseSchema.aiResultOutput: result.output,
      ClipboardDatabaseSchema.aiResultCreatedAt:
          result.createdAt.toIso8601String(),
    };
  }

  String _formatClassification(ClipboardClassifyResponseDto response) {
    final List<String> lines = <String>[
      'Type: ${response.type.name}',
      if (response.labels.isNotEmpty) 'Labels: ${response.labels.join(', ')}',
      if (response.confidence != null)
        'Confidence: ${(response.confidence! * 100).toStringAsFixed(1)}%',
    ];
    return lines.join('\n');
  }

  ClipboardFolder _mapFolder(Map<String, Object?> row) {
    return ClipboardFolder(
      id: row[ClipboardDatabaseSchema.folderId]! as String,
      name: row[ClipboardDatabaseSchema.folderName]! as String,
      description: row[ClipboardDatabaseSchema.folderDescription] as String?,
    );
  }
}
