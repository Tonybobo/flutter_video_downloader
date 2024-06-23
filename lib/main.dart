// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/constants/pages.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
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

  TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
  TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
  TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewProvider(),
        ),
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
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
