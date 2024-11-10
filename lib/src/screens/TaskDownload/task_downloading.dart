import 'package:flutter/material.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/task_provider.dart';
import 'package:video_downloader/src/widgets/download_list_item.dart';

class TaskDownloading extends StatefulWidget {
  const TaskDownloading({super.key});

  @override
  State<TaskDownloading> createState() => _TaskDownloadingState();
}

class _TaskDownloadingState extends State<TaskDownloading> {
  @override
  Widget build(BuildContext context) {
    return _build();
  }

  @override
  void initState() {
    var taskProvider = Provider.of<TaskProvider>(context , listen: false);
    taskProvider.fetchOnGoingTask();
    super.initState();
  }

  Widget _build(){
    var taskProvider = Provider.of<TaskProvider>(context , listen: true);
    var onGoingTask = taskProvider.downloadingTask;
    return onGoingTask.isNotEmpty ? ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              ...onGoingTask.map(
                    (item) {
                  final task = item;
                  if (task == null) {
                    return Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        item!.name!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }
                  return DownloadListItem(
                    data: ItemHolder(task: item, name: item!.name!),
                    onTap: (task) async {
                      taskProvider.deleteTask(task!);
                    },
                    onActionTap: (task) {
                      switch (task.status) {
                        case DownloadTaskStatus.undefined:
                          taskProvider.requestDownload(task);

                        case DownloadTaskStatus.running:
                          taskProvider.pauseDownload(task);

                        case DownloadTaskStatus.paused:
                          taskProvider.resumeDownload(task);

                        case DownloadTaskStatus.canceled:
                          taskProvider.retryDownload(task);

                        case DownloadTaskStatus.failed:
                          taskProvider.retryDownload(task);
                        case DownloadTaskStatus.enqueued:
                          taskProvider.deleteTask(task);
                        default:
                          return;
                      }
                    },
                  );
                },
              )
            ],
          ) : const Center(
      child: Text("No Ongoing Task"),
    );
}
}


