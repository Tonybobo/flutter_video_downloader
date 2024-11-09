import 'package:m3u8_downloader/m3u8_downloader.dart';

class TaskInfo {
  final String? name;
  final String? link;

  TaskInfo({this.name, this.link , this.progress , this.taskId , this.status});

  String? taskId;
  int? progress = 0;

  DownloadTaskStatus? status = DownloadTaskStatus.undefined;
}
