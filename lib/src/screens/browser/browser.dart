import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/browser_app_bar.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/tab_viewer_app_bar.dart';
import 'package:video_downloader/src/screens/browser/widgets/custom_image.dart';
import 'package:video_downloader/src/screens/browser/widgets/empty_tab.dart';
import 'package:video_downloader/src/screens/browser/widgets/tab_viewer.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class Browser extends StatefulWidget {
  const Browser({super.key});

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with SingleTickerProviderStateMixin {
  var _isRestored = false;

  restore() async {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    browserProvider.restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      restore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrowser();
  }

  Widget _buildBrowser() {
    var currentWebViewProvider =
        Provider.of<WebViewProvider>(context, listen: true);

    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);

    browserProvider.addListener(() {
      browserProvider.save();
    });

    currentWebViewProvider.addListener(() {
      browserProvider.save();
    });

    var canshowTabScroller = browserProvider.showTabScroller &&
        browserProvider.webViewTabs.isNotEmpty;

    return IndexedStack(
      index: canshowTabScroller ? 1 : 0,
      children: [
        _buildWebViewTabs(),
        canshowTabScroller ? _buildWebViewTabsViewer() : Container()
      ],
    );
  }

  Widget _buildWebViewTabs() {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        var browserProvider =
            Provider.of<BrowserProvider>(context, listen: false);
        var webViewModel = browserProvider.getCurrentTab()?.webViewProvider;
        var webViewController = webViewModel?.webViewController;

        if (webViewController != null) {
          if (await webViewController.canGoBack()) {
            webViewController.goBack();
          }
        }
      },
      child: Listener(
        onPointerUp: (_) {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
        },
        child: Scaffold(
          appBar: const BrowserAppBar(),
          body: _buildWebViewTabsContent(),
        ),
      ),
    );
  }

  Widget _buildWebViewTabsContent() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    if (browserProvider.webViewTabs.isEmpty) {
      return const EmptyTab();
    }

    for (final webViewTab in browserProvider.webViewTabs) {
      var isCurrentTab = webViewTab.webViewProvider.tabIndex ==
          browserProvider.getCurrentTabIndex();

      if (isCurrentTab) {
        Future.delayed(const Duration(milliseconds: 30), () {
          webViewTabState.currentState?.onShowTab();
        });
      } else {
        webViewTabState.currentState?.onHideTab();
      }
    }

    var stackChildren = <Widget>[
      browserProvider.getCurrentTab() ?? Container(),
    ];
    return Stack(
      children: stackChildren,
    );
  }

  Widget _buildWebViewTabsViewer() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => browserProvider.showTabScroller = false,
      child: Scaffold(
        appBar: const TabViewerAppBar(),
        body: TabViewer(
          currentIndex: browserProvider.getCurrentTabIndex(),
          children: browserProvider.webViewTabs.map((webViewTab) {
            webViewTabState.currentState?.pause();
            var screenshotData = webViewTab.webViewProvider.screenshot;
            Widget screenshotImage = Container(
              decoration: const BoxDecoration(color: Colors.white),
              width: double.infinity,
              child:
                  screenshotData != null ? Image.memory(screenshotData) : null,
            );

            var url = webViewTab.webViewProvider.url;
            var faviconUrl = webViewTab.webViewProvider.favicon != null
                ? webViewTab.webViewProvider.favicon!.url
                : (url != null && ["http", "https"].contains(url.scheme)
                    ? Uri.parse("${url.origin}/favicon.ico")
                    : null);

            var isCurrentTab = browserProvider.getCurrentTabIndex() ==
                webViewTab.webViewProvider.tabIndex;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: isCurrentTab
                      ? Colors.blue
                      : (webViewTab.webViewProvider.isIncognitoMode
                          ? Colors.black
                          : Colors.white),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomImage(
                            url: faviconUrl, maxWidth: 30.0, height: 30.0)
                      ],
                    ),
                    title: Text(
                      webViewTab.webViewProvider.title ??
                          webViewTab.webViewProvider.url?.toString() ??
                          "",
                      maxLines: 2,
                      style: TextStyle(
                        color: webViewTab.webViewProvider.isIncognitoMode ||
                                isCurrentTab
                            ? Colors.white
                            : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      webViewTab.webViewProvider.url?.toString() ?? "",
                      style: TextStyle(
                        color: webViewTab.webViewProvider.isIncognitoMode ||
                                isCurrentTab
                            ? Colors.white60
                            : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (webViewTab.webViewProvider.tabIndex !=
                                    null) {
                                  browserProvider.closeTab(
                                      webViewTab.webViewProvider.tabIndex!);
                                  if (browserProvider.webViewTabs.isEmpty) {
                                    browserProvider.showTabScroller = false;
                                  }
                                }
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 20.0,
                              color:
                                  webViewTab.webViewProvider.isIncognitoMode ||
                                          isCurrentTab
                                      ? Colors.white60
                                      : Colors.black54,
                            ))
                      ],
                    ),
                  ),
                ),
                Expanded(child: screenshotImage)
              ],
            );
          }).toList(),
          onTap: (index) async {
            browserProvider.showTabScroller = false;
            browserProvider.showTab(index);
          },
        ),
      ),
    );
  }
}
