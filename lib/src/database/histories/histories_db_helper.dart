import 'package:video_downloader/src/database/base_db_helper.dart';
import 'package:video_downloader/src/database/histories/histories_model.dart';
import 'package:video_downloader/src/database/queries/query_conditions.dart';

class HistoriesDbHelper {
  HistoriesDbHelper._internal();

  static final HistoriesDbHelper _instance = HistoriesDbHelper._internal();

  static const tableName = 'histories';

  factory HistoriesDbHelper() {
    return _instance;
  }

  static final BaseDbHelper _databaseHelper = BaseDbHelper();

  Future<List<HistoriesModel>> read(QueryConditions query) async {
    final db = await _databaseHelper.database;
    final result = await db.query(tableName,
        orderBy: query.orderBy, limit: query.limit, offset: query.offset);
    return result.map((json) => HistoriesModel.fromMap((json))).toList();
  }

  Future deleteById(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(tableName, where: "_id = ?", whereArgs: [id]);
  }

  Future deleteAll() async {
    final db = await _databaseHelper.database;
    await db.delete(tableName);
  }
}
