import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_downloader/src/database/tables/histories_table.dart';
import 'package:video_downloader/src/database/tables/recents_table.dart';

class BaseDbHelper {
  BaseDbHelper._internal();

  Database? _database;

  static final BaseDbHelper _instance = BaseDbHelper._internal();

  static const _dbName = 'videodownloader.db';

  static const _dbVersion = 1;

  static const tables = [HistoriesTable.onCreate, RecentsTable.onCreate];

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String directory = await getDatabasesPath();
    String path = join(directory, _dbName);
    log("DB Log ===> $path");
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onCreate(Database db, int version) async {
    for (final table in tables) {
      await db.execute(table);
    }
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys= ON');
  }

  factory BaseDbHelper() {
    return _instance;
  }
}
