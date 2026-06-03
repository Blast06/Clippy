class ClipboardDatabaseSchema {
  const ClipboardDatabaseSchema._();

  static const String databaseName = 'clippy.db';
  static const int version = 3;

  static const String itemsTable = 'clipboard_items';
  static const String foldersTable = 'clipboard_folders';
  static const String settingsTable = 'app_settings';
  static const String aiActionResultsTable = 'ai_action_results';

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

  static const String settingKey = 'key';
  static const String settingValue = 'value';

  static const String aiResultId = 'id';
  static const String aiResultItemId = 'item_id';
  static const String aiResultAction = 'action';
  static const String aiResultInput = 'input';
  static const String aiResultOutput = 'output';
  static const String aiResultCreatedAt = 'created_at';

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

  static const String createSettingsTable = '''
    CREATE TABLE $settingsTable (
      $settingKey TEXT PRIMARY KEY,
      $settingValue TEXT NOT NULL
    )
  ''';

  static const String createAiActionResultsTable = '''
    CREATE TABLE $aiActionResultsTable (
      $aiResultId TEXT PRIMARY KEY,
      $aiResultItemId TEXT NOT NULL,
      $aiResultAction TEXT NOT NULL,
      $aiResultInput TEXT NOT NULL,
      $aiResultOutput TEXT NOT NULL,
      $aiResultCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($aiResultItemId) REFERENCES $itemsTable($itemId)
        ON DELETE CASCADE
    )
  ''';
}
