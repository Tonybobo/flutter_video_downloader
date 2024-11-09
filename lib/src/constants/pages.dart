import 'package:flutter/material.dart';
import 'package:video_downloader/src/screens/TaskCompleted/task_completed.dart';
import 'package:video_downloader/src/screens/TaskDownload/task_downloading.dart';
import 'package:video_downloader/src/screens/browser/browser.dart';

const List<Widget> pages = [
  Browser(),
  TaskDownloading(),
  TaskCompletedScreen()
];
