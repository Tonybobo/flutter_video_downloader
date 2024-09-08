import 'package:video_downloader/src/database/recents/recents_db_helper.dart';

class RecentsQueryConditions {
  int? limit;
  int? offset;
  String? orderBy;

  RecentsQueryConditions({limit, offset, orderBy}) {
    this.limit = limit ?? 10;
    this.offset = offset ?? 0;
    this.orderBy = orderBy ?? '${RecentsDbHelper.columnCreatedAt} DESC';
  }
}
