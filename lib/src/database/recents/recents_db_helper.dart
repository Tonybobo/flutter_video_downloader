import 'dart:async';
import 'dart:developer';
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
    final currentRecents = await db.query(tableName  , where: 'authority = ?' , whereArgs: [recents.authority] , limit: 1);
    if(currentRecents.isEmpty){
      await db.insert(tableName, recents.toMap());
    }else{
      final current  = currentRecents.map((json)=> RecentsModel.fromMap(json)).toList();
      final result = current[0];
      result.counts = (result.counts!) + 1;
      await db.update(tableName, result.toMap() , where: '_id = ?', whereArgs: [result.id]);
    }
  }

  Future<List<RecentsModel>> read(QueryConditions query) async {
    final db = await _databaseHelper.database;
    final result = await db.query(tableName,
        limit: query.limit, offset: query.offset, orderBy: query.orderBy);
    log(result.toString());
    return result.map((json) => RecentsModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await _databaseHelper.database;
    await db.close();
  }
}
