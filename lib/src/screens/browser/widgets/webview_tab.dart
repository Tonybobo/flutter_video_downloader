import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_downloader/main.dart';
import 'package:video_downloader/src/database/histories/histories_db_helper.dart';
import 'package:video_downloader/src/database/histories/histories_model.dart';
import 'package:video_downloader/src/database/recents/recents_db_helper.dart';
import 'package:video_downloader/src/database/recents/recents_model.dart';
import 'package:video_downloader/src/models/task_info.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/task_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/javascript_console_result.dart';
import 'package:video_downloader/src/screens/browser/widgets/long_press_alert_dialog.dart';
import 'package:video_downloader/src/utils/util.dart';

final webViewTabState = GlobalKey<_WebViewTabState>();

class WebViewTab extends StatefulWidget {
  const WebViewTab({super.key, required this.webViewProvider});

  final WebViewProvider webViewProvider;

  @override
  State<WebViewTab> createState() => _WebViewTabState();
}

class _WebViewTabState extends State<WebViewTab> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  FindInteractionController? _findInteractionController;
  bool _isWindowClosed = false;
  List<String> m3u8Resources = [];

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
    widget.webViewProvider.webViewController = null;
    widget.webViewProvider.pullToRefreshController = null;
    widget.webViewProvider.findInteractionController = null;

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
    if (widget.webViewProvider.needsToCompleteInitialLoad) {
      widget.webViewProvider.needsToCompleteInitialLoad = false;
      await widget.webViewProvider.webViewController
          ?.loadUrl(urlRequest: URLRequest(url: widget.webViewProvider.url));
    }
  }

  void onHideTab() async {
    pause();
  }

  bool isCurrentTab(WebViewProvider currentwebViewProvider) {
    return currentwebViewProvider.tabIndex == widget.webViewProvider.tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          _buildWebView(),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
                backgroundColor: m3u8Resources.isNotEmpty ? Colors.pinkAccent : Colors.grey,
                onPressed: () {
                  if(m3u8Resources.isNotEmpty){
                    show();
                  }
                },
                child: const Icon(Icons.download,size: 30,),
              ),
          )
        ],
      ),
    );
  }

  void show() {
    var taskProvider = Provider.of<TaskProvider>(context , listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return  SizedBox(
          height: 300, // Set your desired height
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 20.0,
            mainAxisExtent: 100,
          ),
            padding: const EdgeInsets.all(10),
            itemCount: m3u8Resources.length,
            itemBuilder: (context, index) {
              var m3u8Url = m3u8Resources[index];
              var taskInfo = TaskInfo(link: m3u8Url , name: widget.webViewProvider.title, status: DownloadTaskStatus.running , progress: 0);
              var isExisted = !taskProvider.downloadingTask.every((element) => element?.link != taskInfo.link) || !taskProvider.downloadedTask.every((element) => element?.link != taskInfo.link);
              return SizedBox(
                child: ElevatedButton(
                    onPressed:() {
                      if(!isExisted){
                        taskProvider.requestDownload(taskInfo);
                      }
                    },
                    child: isExisted? const Icon(Icons.done): Text(
                      m3u8Url,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ))
              );
            },
          )
        );
      },
    );
  }

  Future<void> saveHistoryAndRecents(WebUri url) async {
    final db = HistoriesDbHelper();
    final recentsDb = RecentsDbHelper();
    final title = await widget.webViewProvider.webViewController?.getTitle();
    await db.create(HistoriesModel(url: url , title: title));
    await recentsDb.create(RecentsModel(authority: url.authority, url: url));
  }

  InAppWebView _buildWebView() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();
    var currentWebViewProvider =
        Provider.of<WebViewProvider>(context, listen: true);

    if (Util.isAndroid()) {
      InAppWebViewController.setWebContentsDebuggingEnabled(
          settings.debuggingEnabled);
    }

    var initialSettings = widget.webViewProvider.settings!;
    initialSettings.isInspectable = settings.debuggingEnabled;
    initialSettings.useOnDownloadStart = true;
    initialSettings.useOnLoadResource = true;
    initialSettings.useShouldOverrideUrlLoading = true;
    initialSettings.javaScriptCanOpenWindowsAutomatically = true;

    initialSettings.userAgent =
        "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36";
    initialSettings.transparentBackground = true;

    initialSettings.safeBrowsingEnabled = true;
    initialSettings.disableDefaultErrorPage = true;
    initialSettings.supportMultipleWindows = true;
    initialSettings.verticalScrollbarThumbColor =
        const Color.fromRGBO(0, 0, 0, 0.5);
    initialSettings.horizontalScrollbarThumbColor =
        const Color.fromRGBO(0, 0, 0, 0.5);

    initialSettings.allowsLinkPreview = false;
    initialSettings.isFraudulentWebsiteWarningEnabled = true;
    initialSettings.disableLongPressContextMenuOnLinks = true;
    initialSettings.allowingReadAccessTo = WebUri('file://$WEB_ARCHIVE_DIR/');

    return InAppWebView(
      keepAlive: widget.webViewProvider.keepAlive,
      initialUrlRequest: URLRequest(url: widget.webViewProvider.url),
      initialSettings: initialSettings,
      windowId: widget.webViewProvider.windowId,
      pullToRefreshController: _pullToRefreshController,
      findInteractionController: _findInteractionController,
      onWebViewCreated: (controller) async {
        initialSettings.transparentBackground = false;
        await controller.setSettings(settings: initialSettings);

        _webViewController = controller;
        widget.webViewProvider.webViewController = controller;
        widget.webViewProvider.pullToRefreshController =
            _pullToRefreshController;
        widget.webViewProvider.findInteractionController =
            _findInteractionController;
        if (Util.isAndroid()) {
          controller.startSafeBrowsing();
        }
        widget.webViewProvider.settings = await controller.getSettings();

        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      onLoadStart: (controller, url) async {
        widget.webViewProvider.isSSL = Util.urlIsSecure(url!);
        widget.webViewProvider.url = url;
        widget.webViewProvider.loaded = false;
        widget.webViewProvider.setLoadedResource([]);
        widget.webViewProvider.setJavascriptConsoleHistories([]);
        m3u8Resources.clear();

        await saveHistoryAndRecents(url);
        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        } else if (widget.webViewProvider.needsToCompleteInitialLoad) {
          controller.stopLoading();
        }
      },
      onLoadStop: (controller, url) async {
        _pullToRefreshController?.endRefreshing();

        widget.webViewProvider.url = url;
        widget.webViewProvider.favicon = null;
        widget.webViewProvider.loaded = true;

        var sslCertificateFuture = _webViewController?.getCertificate();
        var titleFuture = _webViewController?.getTitle();
        var faviconsFuture = _webViewController?.getFavicons();

        var sslCertificate = await sslCertificateFuture;
        if (sslCertificate == null && !Util.isLocalizedContent(url!)) {
          widget.webViewProvider.isSSL = false;
        }

        widget.webViewProvider.title = await titleFuture;

        List<Favicon>? favicons = await faviconsFuture;
        if (favicons != null && favicons.isNotEmpty) {
          for (var fav in favicons) {
            if (widget.webViewProvider.favicon == null) {
              widget.webViewProvider.favicon = fav;
            } else {
              if ((widget.webViewProvider.favicon!.width == null &&
                      !widget.webViewProvider.favicon!.url
                          .toString()
                          .endsWith("favicon.ico")) ||
                  (fav.width != null &&
                      widget.webViewProvider.favicon!.width != null &&
                      fav.width! > widget.webViewProvider.favicon!.width!)) {
                widget.webViewProvider.favicon = fav;
              }
            }
          }
        }

        if (isCurrentTab(currentWebViewProvider)) {
          widget.webViewProvider.needsToCompleteInitialLoad = false;
          currentWebViewProvider.updateWithValue(widget.webViewProvider);

          var screenshotData = _webViewController
              ?.takeScreenshot(
                  screenshotConfiguration: ScreenshotConfiguration(
                      compressFormat: CompressFormat.JPEG, quality: 20))
              .timeout(const Duration(milliseconds: 1500),
                  onTimeout: () => null);
          widget.webViewProvider.screenshot = await screenshotData;
        }
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          _pullToRefreshController?.endRefreshing();
        }

        widget.webViewProvider.progress = progress / 100;

        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      onUpdateVisitedHistory: (controller, url, isReload) async {
        widget.webViewProvider.url = url;
        widget.webViewProvider.title = await _webViewController?.getTitle();

        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      onLongPressHitTestResult: (controller, hitTestResult) async {
        if (LongPressAlertDialog.hitTestResultSupport
            .contains(hitTestResult.type)) {
          var requestFocusNodeHrefResult =
              await _webViewController?.requestFocusNodeHref();
          if (requestFocusNodeHrefResult != null) {
            if (!mounted) return;
            showDialog(
                context: context,
                builder: (context) {
                  return LongPressAlertDialog(
                    webViewProvider: widget.webViewProvider,
                    hitTestResult: hitTestResult,
                    requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                  );
                });
          }
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        Color consoleTextColor = Colors.black;
        Color consoleBackgroundColor = Colors.transparent;
        IconData? consoleIconData;
        Color? consoleIconColor;
        switch (consoleMessage) {
          case ConsoleMessageLevel.ERROR:
            consoleTextColor = Colors.red;
            consoleIconData = Icons.report_problem;
            consoleIconColor = Colors.red;
            break;
          case ConsoleMessageLevel.TIP:
            consoleTextColor = Colors.blue;
            consoleIconData = Icons.info;
            consoleIconColor = Colors.blueAccent;
            break;
          case ConsoleMessageLevel.WARNING:
            consoleBackgroundColor = const Color.fromRGBO(255, 251, 227, 1);
            consoleIconData = Icons.report_problem;
            consoleIconColor = Colors.orangeAccent;
            break;
          default:
            break;
        }

        widget.webViewProvider.addJavascriptConsoleResults(
          JavascriptConsoleResult(
            data: consoleMessage.message,
            textColor: consoleTextColor,
            backgroundColor: consoleBackgroundColor,
            iconData: consoleIconData,
            iconColor: consoleIconColor,
          ),
        );

        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      onLoadResource: (controller, resource) {
        widget.webViewProvider.addLoadedResource(resource);
        if(resource.url.toString().contains(RegExp(r'.m3u8', caseSensitive: false))){
          m3u8Resources.add(resource.url.toString());
        }
        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var url = navigationAction.request.url;
        if (url != null &&
            !["http", "https", "file", "chrome", "data", "javascript", "about"]
                .contains(url.scheme)) {
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
            return NavigationActionPolicy.CANCEL;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null && (sslError.code != null)) {
          if (Util.isIOS() && sslError.code == SslErrorType.UNSPECIFIED) {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          }
          widget.webViewProvider.isSSL = false;
          if (isCurrentTab(currentWebViewProvider)) {
            currentWebViewProvider.updateWithValue(widget.webViewProvider);
          }
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.CANCEL);
        }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onReceivedError: (controller, request, error) async {
        var isForMainFrame = request.isForMainFrame ?? false;
        if (!isForMainFrame) {
          return;
        }

        _pullToRefreshController?.endRefreshing();

        if (Util.isIOS() && error.type == WebResourceErrorType.CANCELLED) {
          // NSURLErrorDomain
          return;
        }

        var errorUrl = request.url;

        _webViewController?.loadData(data: """
          <!DOCTYPE html>
          <html lang="en">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
              <meta http-equiv="X-UA-Compatible" content="ie=edge">
              <style>
              ${await InAppWebViewController.tRexRunnerCss}
              </style>
              <style>
              .interstitial-wrapper {
                  box-sizing: border-box;
                  font-size: 1em;
                  line-height: 1.6em;
                  margin: 0 auto 0;
                  max-width: 600px;
                  width: 100%;
              }
              </style>
          </head>
          <body>
              ${await InAppWebViewController.tRexRunnerHtml}
              <div class="interstitial-wrapper">
                <h1>Website not available</h1>
                <p>Could not load web pages at <strong>$errorUrl</strong> because:</p>
                <p>${error.description}</p>
              </div>
          </body>
              """, baseUrl: errorUrl, historyUrl: errorUrl);

        widget.webViewProvider.url = errorUrl;
        widget.webViewProvider.isSSL = false;

        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      onTitleChanged: (controller, title) async {
        widget.webViewProvider.title = title;
        if (isCurrentTab(currentWebViewProvider)) {
          currentWebViewProvider.updateWithValue(widget.webViewProvider);
        }
      },
      onCreateWindow: (controller, createWindowAction) async {
        var webViewTab = WebViewTab(
          key: GlobalKey(),
          webViewProvider: WebViewProvider(
            url: WebUri("about:blank"),
            windowId: createWindowAction.windowId,
          ),
        );
        browserProvider.addTab(webViewTab);

        return true;
      },
      onCloseWindow: (controller) {
        if (_isWindowClosed) return;
        _isWindowClosed = true;
        if (widget.webViewProvider.tabIndex != null) {
          browserProvider.closeTab(widget.webViewProvider.tabIndex!);
        }
      },
      onPermissionRequest: (controller, permissionRequest) async {
        return PermissionResponse(
          resources: permissionRequest.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onReceivedHttpAuthRequest: (controller, challenge) async {
        return;
      },
    );
  }
}
