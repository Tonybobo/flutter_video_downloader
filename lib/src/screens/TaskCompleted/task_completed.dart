import 'package:flutter/material.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/task_provider.dart';
import 'package:video_downloader/src/widgets/download_list_item.dart';

class TaskCompletedScreen extends StatefulWidget {
  const TaskCompletedScreen({super.key});

  @override
  State<TaskCompletedScreen> createState() => _TaskCompletedScreenState();
}

class _TaskCompletedScreenState extends State<TaskCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    return _build();
  }

  Widget _build(){
    var taskProvider = Provider.of<TaskProvider>(context , listen: true);
    var onGoingTask = taskProvider.downloadingTask;
    return FutureBuilder(
        future: taskProvider.fetchOnGoingTask(),
        builder: (context , snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Text(
                "No Task",
              ),
            );
          }
          return ListView(
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
          );
        }
    );
  }
}

