// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/constants/pages.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/task_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';

late final String WEB_ARCHIVE_DIR;
late final double TAB_VIEWER_BOTTOM_OFFSET_1;
late final double TAB_VIEWER_BOTTOM_OFFSET_2;
late final double TAB_VIEWER_BOTTOM_OFFSET_3;

const double TAB_VIEWER_TOP_OFFSET_1 = 0.0;
const double TAB_VIEWER_TOP_OFFSET_2 = 10.0;
const double TAB_VIEWER_TOP_OFFSET_3 = 20.0;

const double TAB_VIEWER_TOP_SCALE_TOP_OFFSET = 250.0;
const double TAB_VIEWER_TOP_SCALE_BOTTOM_OFFSET = 230.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WEB_ARCHIVE_DIR = (await getApplicationSupportDirectory()).path;
  await M3u8Downloader.initialize(debug:true);

  TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
  TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
  TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewProvider(),
        ),
        ChangeNotifierProvider(create: (context)=> TaskProvider()),
        ChangeNotifierProxyProvider<WebViewProvider, BrowserProvider>(
          create: (BuildContext context) => BrowserProvider(),
          update: (context, webViewProvider, browserProvider) {
            browserProvider!.setCurrentWebViewProvider(webViewProvider);
            return browserProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Downloader',
      theme: FlexThemeData.light(scheme: FlexScheme.indigoM3),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.indigoM3),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late bool _permissionReady;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    _retryRequestPermission();
    M3u8Downloader.registerCallback(downloadCallback, step: 1);
    initConfig();
    _permissionReady = false;
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void initConfig() async {
    String? saveDir = await _getDownloadPath();
    M3u8Downloader.config(saveDir: saveDir, connTimeout: 60, readTimeout: 60);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      final taskProvider = Provider.of<TaskProvider>(context , listen: false);
      final taskId = (data as List<dynamic>)[0] as String;
      final status = DownloadTaskStatus.fromInt(data[1] as int);
      final progress = data[2] as int;
      final size = data[3] ?? "";
      // ignore: avoid_print
      taskProvider.setTaskProgress(taskId, progress, status);
      print(data);

      // ignore: avoid_print
      print(
        'Callback on UI Isolate: '
            'task ($taskId) is in status ($status) and progress ($progress) and current file size ($size)',
      );
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, int status, int progress, String size) {
    // ignore: avoid_print
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress, size]);
  }

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();
    if (hasGranted) {
      await _getDownloadPath();
    }

    setState(() {
      _permissionReady = hasGranted;
    });
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) return false;

    if (Platform.isAndroid) {

      final status = await Permission.videos.isGranted;
      if (status) {
        return true;
      }

      final result = await Permission.videos.request();
      return result.isGranted;
    }

    throw StateError('Unknown Platform');
  }

  Widget _buildNoPermissionWarning() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Grant Storage Permission to continue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _retryRequestPermission,
            child: const Text(
              'Retry',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          )
        ],
      ),
    );
  }

  Future<String?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download/video_downloader');
        if (!directory.existsSync()) await directory.create();
      }
    } catch (err) {
      log("download folder error : $err");
    }
    log("directory : $directory");
    return directory!.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _permissionReady ? IndexedStack(
          index: _selectedIndex,
          children: pages ,
        ) : _buildNoPermissionWarning(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.web), label: "Browser"),
          BottomNavigationBarItem(
              icon: Icon(Icons.downloading), label: "Downloading"),
          BottomNavigationBarItem(
              icon: Icon(Icons.download_done), label: "Completed"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
