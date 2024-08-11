import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/custom_image.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class TabViewer extends StatefulWidget {
  const TabViewer({super.key});

  @override
  State<TabViewer> createState() => _TabViewerState();
}

class _TabViewerState extends State<TabViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildGridTabViewer());
  }

  Widget _buildGridTabViewer() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var currentIndex = browserProvider.getCurrentTabIndex();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 20.0,
        mainAxisExtent: 250,
      ),
      padding: const EdgeInsets.all(10),
      itemCount: browserProvider.webViewTabs.length,
      itemBuilder: (context, index) => _buildGridCardViewer(
        webViewTab: browserProvider.webViewTabs[index],
        currentIndex: currentIndex,
      ),
    );
  }

  Widget _buildGridCardViewer(
      {required WebViewTab webViewTab, required int currentIndex}) {
    var screenshotData = webViewTab.webViewProvider.screenshot;
    Widget? screenshotImage;
    if (screenshotData != null) {
      screenshotImage = ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        child: Image.memory(
          screenshotData,
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      screenshotImage = const Text("No Image Available");
    }

    var url = webViewTab.webViewProvider.url;
    var faviconUrl = webViewTab.webViewProvider.favicon != null
        ? webViewTab.webViewProvider.favicon!.url
        : (url != null && ["http", "https"].contains(url.scheme)
            ? Uri.parse("${url.origin}/favicon.ico")
            : null);
    var isCurrentTab =
        webViewTab.webViewProvider.tabIndex == currentIndex ? true : false;
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);

    return InkWell(
      onTap: () async {
        browserProvider.showTabScroller = false;
        browserProvider.showTab(webViewTab.webViewProvider.tabIndex!);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: isCurrentTab ? Colors.blue : Colors.black54,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 5.0),
              minLeadingWidth: 0.0,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImage(
                    url: faviconUrl,
                    maxWidth: 20.0,
                    maxHeight: 20.0,
                    height: 20.0,
                  )
                ],
              ),
              title: Text(
                webViewTab.webViewProvider.title ??
                    webViewTab.webViewProvider.url.toString(),
                maxLines: 1,
                style: TextStyle(
                  color: webViewTab.webViewProvider.isIncognitoMode
                      ? Colors.grey
                      : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(maxHeight: 26),
                    iconSize: 20,
                    icon: Icon(
                      Icons.close,
                      color: webViewTab.webViewProvider.isIncognitoMode
                          ? Colors.grey
                          : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (webViewTab.webViewProvider.tabIndex != null) {
                          browserProvider
                              .closeTab(webViewTab.webViewProvider.tabIndex!);
                          if (browserProvider.webViewTabs.isEmpty) {
                            browserProvider.showTabScroller = false;
                          }
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(child: screenshotImage)
        ],
      ),
    );
  }
}
