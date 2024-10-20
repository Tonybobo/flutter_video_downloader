import 'package:video_downloader/src/database/base_db_helper.dart';
import 'package:video_downloader/src/database/pastwebsites/past_websites_model.dart';

class PastWebsitesDbHelper {

  PastWebsitesDbHelper._internal();

  static final PastWebsitesDbHelper _instance = PastWebsitesDbHelper._internal();

  static const tableName = 'pastWebsites';

  factory PastWebsitesDbHelper() {
  return _instance;
  }

  static final BaseDbHelper _databaseHelper = BaseDbHelper();

  Future create(PastWebsitesModel pastWebsites) async {
  final db = await _databaseHelper.database;
  final currentWebsites = await db.query(tableName , where: "_id = ?" , whereArgs: [pastWebsites.id] , limit: 1);
  if(currentWebsites.isEmpty){
    await db.insert(tableName, pastWebsites.toMap());
  }else{
    await db.update(tableName, pastWebsites.toMap() , where: '_id = ?',whereArgs: [pastWebsites.id]);
  }
  }


  Future<List<PastWebsitesModel>> read() async {
  final db = await _databaseHelper.database;
  final result = await db.query(tableName,where: "_id = ?" , whereArgs: ["browser"], limit: 1);
  return result.map((ele)=> PastWebsitesModel.fromMap(ele)).toList();
  }
}