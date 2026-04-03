import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../database/clipboard_database_schema.dart';

class ClipboardDatabaseService {
  ClipboardDatabaseService();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final String databasesPath = await getDatabasesPath();
    final String databasePath = path.join(
      databasesPath,
      ClipboardDatabaseSchema.databaseName,
    );

    _database = await openDatabase(
      databasePath,
      version: ClipboardDatabaseSchema.version,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (Database db, int version) async {
        await db.execute(ClipboardDatabaseSchema.createFoldersTable);
        await db.execute(ClipboardDatabaseSchema.createItemsTable);
      },
    );

    return _database!;
  }

  Future<List<Map<String, Object?>>> fetchItems() async {
    final Database db = await database;
    return db.query(
      ClipboardDatabaseSchema.itemsTable,
      orderBy: '${ClipboardDatabaseSchema.itemCreatedAt} DESC',
    );
  }

  Future<List<Map<String, Object?>>> fetchFolders() async {
    final Database db = await database;
    return db.query(
      ClipboardDatabaseSchema.foldersTable,
      orderBy: ClipboardDatabaseSchema.folderName,
    );
  }

  Future<void> insertItem(Map<String, Object?> values) async {
    final Database db = await database;
    await db.insert(
      ClipboardDatabaseSchema.itemsTable,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItemFavorite({
    required String id,
    required bool isFavorite,
  }) async {
    final Database db = await database;
    await db.update(
      ClipboardDatabaseSchema.itemsTable,
      <String, Object?>{
        ClipboardDatabaseSchema.itemIsFavorite: isFavorite ? 1 : 0,
      },
      where: '${ClipboardDatabaseSchema.itemId} = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<Map<String, Object?>?> fetchItemById(String id) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      ClipboardDatabaseSchema.itemsTable,
      where: '${ClipboardDatabaseSchema.itemId} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first;
  }

  Future<void> upsertFolder(Map<String, Object?> values) async {
    final Database db = await database;
    await db.insert(
      ClipboardDatabaseSchema.foldersTable,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
