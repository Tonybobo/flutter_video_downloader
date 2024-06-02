import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/src/constants/pages.dart';

void main() {
  runApp(const MyApp());
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
  var currentTime;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (_) async {
            if (_selectedIndex == 0) {
              SystemNavigator.pop();
            } else {
              setState(() {
                _selectedIndex = 0;
              });
            }
          },
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
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
