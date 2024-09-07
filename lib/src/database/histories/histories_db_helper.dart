import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HistoriesDbHelper {
  HistoriesDbHelper._internal();

  static final HistoriesDbHelper _instance = HistoriesDbHelper._internal();

  static const tableName = 'histories';

  static const columnId = '_id';

  static const columnUrl = 'url';

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
    await db.execute(''' ''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys= ON');
  }

  factory HistoriesDbHelper() {
    return _instance;
  }
}
