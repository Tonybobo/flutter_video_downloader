import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/browser_app_bar.dart';
import 'package:video_downloader/src/screens/browser/widgets/empty_tab.dart';
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
    return const Text("Tabs Viewer");
  }
}
