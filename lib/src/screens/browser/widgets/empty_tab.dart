import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/models/web_view.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({super.key});

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  final _controller = TextEditingController();

  void openNewTab(String value) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();

    browserProvider.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
        url: WebUri(value.startsWith("http")
            ? value
            : settings.searchEngine.searchUrl + value),
        javascriptConsoleResult: [],
        javascriptConsoleHistory: [],
        loadedResource: [],
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
            Image(image: AssetImage(settings.searchEngine.assetIcon)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => openNewTab(value),
                    textInputAction: TextInputAction.go,
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle:
                          TextStyle(color: Colors.black54, fontSize: 25.0),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 25.0),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    openNewTab(_controller.text);
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 25.0,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
