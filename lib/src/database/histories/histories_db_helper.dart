import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_downloader/src/database/histories/histories_model.dart';
import 'package:video_downloader/src/database/queries/query_conditions.dart';

class HistoriesDbHelper {
  HistoriesDbHelper._internal();

  static final HistoriesDbHelper _instance = HistoriesDbHelper._internal();

  static const tableName = 'histories';

  static const columnId = '_id';

  static const columnTitle = 'title';

  static const columnUrl = 'url';

  static const columnCreatedAt = 'createdAt';

  static const _dbName = 'videoDownloader.db';

  static const _dbVersion = 1;

  Database? _database;

  factory HistoriesDbHelper() {
    return _instance;
  }

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
        $columnTitle TEXT ,
        $url TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
     )
    ''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys= ON');
  }

  Future create(HistoriesModel history) async {
    final db = await _instance.database;
    await db.insert(tableName, history.toMap());
  }

  Future<List<HistoriesModel>> read(QueryConditions query) async {
    final db = await _instance.database;
    final result = await db.query(tableName,
        orderBy: query.orderBy, limit: query.limit, offset: query.offset);
    return result.map((json) => HistoriesModel.fromMap((json))).toList();
  }

  Future deleteById(int id) async {
    final db = await _instance.database;
    await db.delete(tableName, where: "_id = ?", whereArgs: [id]);
  }

  Future deleteAll() async {
    final db = await _instance.database;
    await db.delete(tableName);
  }
}
