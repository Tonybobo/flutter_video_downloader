import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/models/web_view.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/utils/util.dart';

final webViewTabState = GlobalKey<_WebViewTabState>();

class WebViewTab extends StatefulWidget {
  const WebViewTab({super.key, required this.webViewModel});

  final WebViewModel webViewModel;

  @override
  State<WebViewTab> createState() => _WebViewTabState();
}

class _WebViewTabState extends State<WebViewTab> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  FindInteractionController? _findInteractionController;
  bool _isWindowClosed = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.blue),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                _webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                _webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await _webViewController?.getUrl()));
              }
            },
          );
    _findInteractionController = FindInteractionController();
  }

  @override
  void dispose() {
    _webViewController = null;
    widget.webViewModel.webViewController = null;
    widget.webViewModel.pullToRefreshController = null;
    widget.webViewModel.findInteractionController = null;

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_webViewController != null && Util.isAndroid()) {
      if (state == AppLifecycleState.paused) {
        pauseAll();
      } else {
        resumeAll();
      }
    }
  }

  void pauseAll() {
    if (Util.isAndroid()) {
      _webViewController?.pause();
    }
    _webViewController?.pauseTimers();
  }

  void resumeAll() {
    if (Util.isAndroid()) {
      _webViewController?.resume();
    }
    _webViewController?.resumeTimers();
  }

  void pause() {
    if (Util.isAndroid()) {
      _webViewController?.pause();
    }
  }

  void resume() {
    if (Util.isAndroid()) {
      _webViewController?.resume();
    }
  }

  void onShowTab() async {
    resume();
    if (widget.webViewModel.needsToCompleteInitialLoad) {
      widget.webViewModel.needsToCompleteInitialLoad = false;
      await widget.webViewModel.webViewController
          ?.loadUrl(urlRequest: URLRequest(url: widget.webViewModel.url));
    }
  }

  void onHideTab() async {
    pause();
  }

  InAppWebView _buildWebView() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    return InAppWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildWebView(),
    );
  }
}
