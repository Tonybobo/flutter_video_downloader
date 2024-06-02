import 'package:flutter/material.dart';
import 'package:video_downloader/src/screens/TaskCompleted/taskCompleted.dart';
import 'package:video_downloader/src/screens/TaskDownload/taskDownloading.dart';
import 'package:video_downloader/src/screens/browser/browser.dart';

const List<Widget> pages = [
  Browser(),
  TaskDownlodingScreen(),
  TaskCompletedScreen()
];
