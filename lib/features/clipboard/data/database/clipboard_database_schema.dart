class ClipboardDatabaseSchema {
  const ClipboardDatabaseSchema._();

  static const String databaseName = 'clippy.db';
  static const int version = 1;

  static const String itemsTable = 'clipboard_items';
  static const String foldersTable = 'clipboard_folders';

  static const String itemId = 'id';
  static const String itemContent = 'content';
  static const String itemCreatedAt = 'created_at';
  static const String itemType = 'type';
  static const String itemIsFavorite = 'is_favorite';
  static const String itemFolderId = 'folder_id';
  static const String itemTags = 'tags';

  static const String folderId = 'id';
  static const String folderName = 'name';
  static const String folderDescription = 'description';

  static const String createFoldersTable = '''
    CREATE TABLE $foldersTable (
      $folderId TEXT PRIMARY KEY,
      $folderName TEXT NOT NULL,
      $folderDescription TEXT
    )
  ''';

  static const String createItemsTable = '''
    CREATE TABLE $itemsTable (
      $itemId TEXT PRIMARY KEY,
      $itemContent TEXT NOT NULL,
      $itemCreatedAt TEXT NOT NULL,
      $itemType TEXT NOT NULL,
      $itemIsFavorite INTEGER NOT NULL DEFAULT 0,
      $itemFolderId TEXT,
      $itemTags TEXT NOT NULL DEFAULT '[]',
      FOREIGN KEY ($itemFolderId) REFERENCES $foldersTable($folderId)
    )
  ''';
}
