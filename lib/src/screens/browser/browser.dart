import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';

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
        var webViewModel = browserProvider.getCurrentTab()?.webViewModel;
        var webViewController = webViewModel?.webViewController;

        if (webViewController != null) {
          if (await webViewController.canGoBack()) {
            webViewController.goBack();
          }
        }

        if (webViewModel != null && webViewModel.tabIndex != null) {
          setState(() {
            browserProvider.closeTab(webViewModel.tabIndex!);
          });
          if (mounted) {
            FocusScope.of(context).unfocus();
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
          // appBar: Text("App Bar"),
          body: _buildWebViewTabsContent(),
        ),
      ),
    );
  }

  Widget _buildWebViewTabsContent() {
    return const Text("Web View Tabs Content");
  }

  Widget _buildWebViewTabsViewer() {
    return const Text("Tabs Viewer");
  }
}
