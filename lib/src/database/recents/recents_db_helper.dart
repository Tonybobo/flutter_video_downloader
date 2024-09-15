import 'dart:async';
import 'package:video_downloader/src/database/base_db_helper.dart';
import 'package:video_downloader/src/database/queries/query_conditions.dart';
import 'package:video_downloader/src/database/recents/recents_model.dart';

class RecentsDbHelper {
  RecentsDbHelper._internal();

  static final RecentsDbHelper _instance = RecentsDbHelper._internal();

  static const tableName = 'recents';

  static final BaseDbHelper _databaseHelper = BaseDbHelper();

  factory RecentsDbHelper() {
    return _instance;
  }

  Future create(RecentsModel recents) async {
    final db = await _databaseHelper.database;
    await db.insert(tableName, recents.toMap());
  }

  Future<List<RecentsModel>> read(QueryConditions query) async {
    final db = await _databaseHelper.database;
    final result = await db.query(tableName,
        limit: query.limit, offset: query.offset, orderBy: query.orderBy);
    return result.map((json) => RecentsModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await _databaseHelper.database;
    await db.close();
  }
}
