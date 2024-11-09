import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:video_downloader/src/models/task_info.dart';

class DownloadItem {
  final String url;
  final String name;

  const DownloadItem({required this.url , required this.name});
}


class TaskProvider extends ChangeNotifier {

  final List<TaskInfo?> downloadingTask = [];
  final List<TaskInfo?> downloadedTask = [];

  UnmodifiableListView<TaskInfo> get ongoingTask => UnmodifiableListView(downloadingTask as Iterable<TaskInfo>);

  UnmodifiableListView<TaskInfo> get finishedTask => UnmodifiableListView(downloadedTask as Iterable<TaskInfo>);

  setTaskProgress(String taskId , int progress, DownloadTaskStatus status){
    final currentTaskIndex = downloadingTask.indexWhere((ele)=> ele!.taskId == taskId);
    if(status == DownloadTaskStatus.complete){
      downloadingTask[currentTaskIndex]!.status = DownloadTaskStatus.complete;
      downloadingTask[currentTaskIndex]!.progress = 100;
      downloadedTask.add(downloadingTask[currentTaskIndex]);
      downloadingTask.removeAt(currentTaskIndex);
    }
    downloadingTask[currentTaskIndex]?.progress = progress;
    notifyListeners();
  }


  Future<void> fetchOnGoingTask() async{
    final pendingTasks = await M3u8Downloader.loadTasksWithQuery(
        query:"select * from task where status = 1"
    );
    downloadingTask.addAll(
      pendingTasks!.map((e)=> TaskInfo(name: e.filename , link: e.url, progress: e.progress , status: e.status , taskId: e.taskId ))
    );
    notifyListeners();
  }
  Future<void> deleteTask(TaskInfo task) async {
    await M3u8Downloader.remove(taskId: task.taskId!);
    var currentOngoingTask = downloadingTask.indexWhere((ele)=> ele!.taskId == task.taskId);
    if(currentOngoingTask == -1){
      currentOngoingTask = downloadedTask.indexWhere((ele)=> ele!.taskId == task.taskId);
      downloadedTask.removeAt(currentOngoingTask);
    }else{
      downloadingTask.removeAt(currentOngoingTask);
    }
  }

  Future<void> fetchCompletedTask() async{
    final completedTasks = await M3u8Downloader.loadTasksWithQuery(
        query:"select * from task where status = 3"
    );
    downloadedTask.addAll(
        completedTasks!.map((e)=> TaskInfo(name: e.filename , link: e.url, progress: e.progress , status: e.status , taskId: e.taskId ))
    );
    notifyListeners();
  }

  Future<void> requestDownload(TaskInfo task) async{
    task.taskId = await M3u8Downloader.enqueue(url: task.link!, fileName: task.name!);
    downloadingTask.add(task);
    notifyListeners();
  }

  Future<void> pauseDownload(TaskInfo task) async {
    await M3u8Downloader.pause(taskId: task.taskId!);
    final currentTaskIndex = downloadingTask.indexWhere((ele)=> ele!.taskId == task.taskId);
    if(currentTaskIndex != -1){
      downloadingTask[currentTaskIndex]?.status = DownloadTaskStatus.paused;
    }
    notifyListeners();
  }

  Future<void> resumeDownload(TaskInfo task) async {
    final newTaskId = await M3u8Downloader.resume(taskId: task.taskId!);
    final currentTaskIndex = downloadingTask.indexWhere((ele)=> ele!.taskId == task.taskId);
    if(currentTaskIndex != -1){
      downloadingTask[currentTaskIndex]?.status = DownloadTaskStatus.running;
      downloadingTask[currentTaskIndex]?.taskId =newTaskId;
    }
    notifyListeners();
  }

  Future<void> retryDownload(TaskInfo task) async {
    final newTaskId = await M3u8Downloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
    final currentTaskIndex = downloadingTask.indexWhere((ele)=> ele!.taskId == task.taskId);
    if(currentTaskIndex != -1){
      downloadingTask[currentTaskIndex]?.status = DownloadTaskStatus.running;
      downloadingTask[currentTaskIndex]?.taskId =newTaskId;
    }
    notifyListeners();
  }

}