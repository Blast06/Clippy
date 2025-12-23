import 'package:uuid/uuid.dart';

enum ClipboardItemType { text, url, number, unknown }

class ClipboardItem {
  ClipboardItem({
    required this.content,
    required this.createdAt,
    this.type = ClipboardItemType.unknown,
    this.isFavorite = false,
    this.folderId,
    this.tags = const <String>[],
  }) : id = const Uuid().v4();

  ClipboardItem.withId({
    required this.id,
    required this.content,
    required this.createdAt,
    this.type = ClipboardItemType.unknown,
    this.isFavorite = false,
    this.folderId,
    this.tags = const <String>[],
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final ClipboardItemType type;
  final bool isFavorite;
  final String? folderId;
  final List<String> tags;

  ClipboardItem copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    ClipboardItemType? type,
    bool? isFavorite,
    String? folderId,
    List<String>? tags,
  }) {
    return ClipboardItem.withId(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
    );
  }
}
