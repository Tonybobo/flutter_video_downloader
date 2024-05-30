import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewModel {
  int? tabIndex;
  WebUri? url;
  String? title;
  Favicon? favicon;
  double progress;
  bool loaded;
  bool isDesktopMode;
  bool isIncognitoMode;
  List<Widget> javascriptConsoleResult;
  List<String> javascriptConsoleHistory;
  List<LoadedResource> loadedResource;
  bool isSSL;
  int? windowId;
  InAppWebViewSettings? settings;
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  FindInteractionController? findInteractionController;
  Uint8List? screenshot;
  bool needsToCompleteInitialLoad;
  final keepAlive = InAppWebViewKeepAlive();

  WebViewModel({
    this.tabIndex,
    this.url,
    this.title,
    this.favicon,
    this.progress = 0.0,
    this.isDesktopMode = false,
    this.isIncognitoMode = false,
    required this.javascriptConsoleResult,
    required this.javascriptConsoleHistory,
    required this.loadedResource,
    this.loaded = false,
    this.isSSL = false,
    this.windowId,
    this.settings,
    this.webViewController,
    this.pullToRefreshController,
    this.findInteractionController,
    this.screenshot,
    this.needsToCompleteInitialLoad = true,
  });

  static WebViewModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? WebViewModel(
            tabIndex: map["tabIndex"],
            url: map["url"] != null ? WebUri(map["url"]) : null,
            title: map["title"],
            favicon: map["favicon"] != null
                ? Favicon(
                    url: WebUri(map["favicon"]["url"]),
                    rel: map["favicon"]["url"],
                    width: map["favicon"]["width"],
                    height: map["favicon"]["height"],
                  )
                : null,
            progress: map["progress"],
            isDesktopMode: map["isDesktopMode"],
            isIncognitoMode: map["isIncognitoMode"],
            javascriptConsoleHistory:
                map["javascriptConsoleHistory"]?.cast<String>(),
            javascriptConsoleResult:
                map["javascriptConsoleResult"]?.cast<Widget>(),
            loadedResource: map["loadedResource"]?.cast<Widget>(),
            isSSL: map["isSSL"],
            settings: InAppWebViewSettings.fromMap(
              map["settings"],
            ),
          )
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "tabIndex": tabIndex,
      "url": url?.toString(),
      "title": title,
      "favicon": favicon?.toMap(),
      "progress": progress,
      "isDesktopMode": isDesktopMode,
      "isIncognitoMode": isIncognitoMode,
      "javascriptConsoleHistory": javascriptConsoleHistory,
      "isSSL": isSSL,
      "settings": settings?.toMap(),
      "screenshot": settings?.toMap(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
