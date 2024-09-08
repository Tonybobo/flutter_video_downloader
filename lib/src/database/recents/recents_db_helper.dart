import 'dart:async';
import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_downloader/src/database/recents/recents_query_conditions.dart';
import 'package:video_downloader/src/database/recents/recents_model.dart';

class RecentsDbHelper {
  RecentsDbHelper._internal();

  static final RecentsDbHelper _instance = RecentsDbHelper._internal();

  static const tableName = 'recents';

  static const columnId = '_id';

  static const columnAuthority = 'authority';

  static const columnUrl = 'url';

  static const columnCount = 'counts';

  static const columnCreatedAt = 'createdAt';

  static const _dbName = 'videoDownloader.db';

  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  factory RecentsDbHelper() {
    return _instance;
  }

  Future<Database> _initDatabase() async {
    String directory = await getDatabasesPath();
    log("DB Log ===> $directory");
    String path = join(directory, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName IF NOT EXISTS (
        $columnId INTEGER PRIMARY KEY AUTOCREMENT NOT NULL,
        $columnAuthority TEXT NOT NULL,
        $url TEXT NOT NULL,
        $columnCount INTERGER NOT NULL DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL,

      ) 
    ''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys= ON');
  }

  Future create(RecentsModel recents) async {
    final db = await _instance.database;
    await db.insert(_dbName, recents.toMap());
  }

  Future<List<RecentsModel>> read(RecentsQueryConditions query) async {
    final db = await _instance.database;
    final result = await db.query(_dbName,
        limit: query.limit, offset: query.offset, orderBy: query.orderBy);
    return result.map((json) => RecentsModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await _instance.database;
    await db.close();
  }
}
