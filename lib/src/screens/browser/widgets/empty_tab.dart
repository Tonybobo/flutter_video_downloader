import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/database/histories/histories_db_helper.dart';
import 'package:video_downloader/src/database/histories/histories_model.dart';
import 'package:video_downloader/src/database/queries/query_conditions.dart';
import 'package:video_downloader/src/database/recents/recents_db_helper.dart';
import 'package:video_downloader/src/database/recents/recents_model.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({super.key});

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  final _controller = TextEditingController();
  final queryCondition = QueryConditions();

  Future<List<RecentsModel>> fetchRecents() async {
    final result =  await RecentsDbHelper().read(queryCondition);
    setState(() {
      queryCondition.offset += 5;
    });
    return result;
  }

  Future<List<HistoriesModel>> fetchHistories() async {
    final result =  await HistoriesDbHelper().read(queryCondition);
    setState(() {
      queryCondition.offset += 5;
    });
    return result;
  }


  void openNewTab(String value) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var settings = browserProvider.getSettings();

    browserProvider.addTab(WebViewTab(
      key: GlobalKey(),
      webViewProvider: WebViewProvider(
        url: WebUri(value.startsWith("http")
            ? value
            : settings.searchEngine.searchUrl + value),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              settings.searchEngine.name,
              style: const TextStyle(fontSize: 100.0, letterSpacing: 1.0),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => openNewTab(value),
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      contentPadding: const EdgeInsets.all(20.0),
                      hintText: "Search",
                      hintStyle: const TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 25.0),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
