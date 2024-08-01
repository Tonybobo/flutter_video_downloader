import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_downloader/src/models/web_view.dart';

class WebViewProvider extends ChangeNotifier {
  WebViewModel _webViewModel = WebViewModel();

  WebViewProvider(
      {WebViewModel? webViewModel,
      WebUri? url,
      List<Widget>? javascriptConsoleResult,
      List<String>? javascriptConsoleHistory,
      List<LoadedResource>? loadedResources,
      int? windowId,
      bool? isIncognitoMode}) {
    _webViewModel.windowId = windowId;
    _webViewModel.isIncognitoMode = isIncognitoMode ?? false;
    _webViewModel = webViewModel ?? WebViewModel();
    _webViewModel.javascriptConsoleResult =
        javascriptConsoleResult ?? <Widget>[];
    _webViewModel.url = url;
    _webViewModel.javascriptConsoleHistory =
        javascriptConsoleHistory ?? <String>[];
    _webViewModel.loadedResource = loadedResources ?? <LoadedResource>[];
  }

  int? get tabIndex => _webViewModel.tabIndex;

  set tabIndex(int? value) {
    if (value != _webViewModel.tabIndex) {
      _webViewModel.tabIndex = value;
      notifyListeners();
    }
  }

  WebUri? get url => _webViewModel.url;

  set url(WebUri? value) {
    if (value != _webViewModel.url) {
      _webViewModel.url = value;
      notifyListeners();
    }
  }

  String? get title => _webViewModel.title;

  set title(String? value) {
    if (value != _webViewModel.title) {
      _webViewModel.title = value;
      notifyListeners();
    }
  }

  Favicon? get favicon => _webViewModel.favicon;

  set favicon(Favicon? value) {
    if (value != _webViewModel.favicon) {
      _webViewModel.favicon = value;
      notifyListeners();
    }
  }

  double get progress => _webViewModel.progress;

  set progress(double value) {
    if (value != _webViewModel.progress) {
      _webViewModel.progress = value;
      notifyListeners();
    }
  }

  bool get loaded => _webViewModel.loaded;

  set loaded(bool value) {
    if (value != _webViewModel.loaded) {
      _webViewModel.loaded = value;
      notifyListeners();
    }
  }

  bool get isDesktopMode => _webViewModel.isDesktopMode;

  set isDesktopMode(bool value) {
    if (value != _webViewModel.isDesktopMode) {
      _webViewModel.isDesktopMode = value;
      notifyListeners();
    }
  }

  bool get isIncognitoMode => _webViewModel.isDesktopMode;

  set isIncognitoMode(bool value) {
    if (value != _webViewModel.isIncognitoMode) {
      _webViewModel.isIncognitoMode = value;
      notifyListeners();
    }
  }

  UnmodifiableListView<String> get javascriptConsoleHistory =>
      UnmodifiableListView(_webViewModel.javascriptConsoleHistory!);

  setJavascriptConsoleHistories(List<String> value) {
    if (!listEquals(value, _webViewModel.javascriptConsoleHistory)) {
      _webViewModel.javascriptConsoleHistory = value;
      notifyListeners();
    }
  }

  UnmodifiableListView<Widget> get javascriptConsoleResult =>
      UnmodifiableListView(_webViewModel.javascriptConsoleResult!);

  setJavascriptConsoleResults(List<Widget> value) {
    if (!listEquals(value, _webViewModel.javascriptConsoleResult)) {
      _webViewModel.javascriptConsoleResult = value;
      notifyListeners();
    }
  }

  void addJavascriptConsoleResults(Widget value) {
    _webViewModel.javascriptConsoleResult?.add(value);
    notifyListeners();
  }

  UnmodifiableListView<LoadedResource> get loadedResource =>
      UnmodifiableListView(_webViewModel.loadedResource!);

  setLoadedResource(List<LoadedResource> value) {
    if (!listEquals(value, _webViewModel.loadedResource)) {
      _webViewModel.loadedResource = value;
      notifyListeners();
    }
  }

  void addLoadedResource(LoadedResource value) {
    _webViewModel.loadedResource?.add(value);
    notifyListeners();
  }

  bool get isSSL => _webViewModel.isSSL;

  set isSSL(bool value) {
    if (value != _webViewModel.isSSL) {
      _webViewModel.isSSL = value;
      notifyListeners();
    }
  }

  InAppWebViewController? get webViewController =>
      _webViewModel.webViewController;

  set webViewController(InAppWebViewController? value) {
    _webViewModel.webViewController = value;
  }

  PullToRefreshController? get pullToRefreshController =>
      _webViewModel.pullToRefreshController;

  set pullToRefreshController(PullToRefreshController? value) {
    _webViewModel.pullToRefreshController = value;
  }

  FindInteractionController? get findInteractionController =>
      _webViewModel.findInteractionController;

  set findInteractionController(FindInteractionController? value) {
    _webViewModel.findInteractionController = value;
  }

  bool get needsToCompleteInitialLoad =>
      _webViewModel.needsToCompleteInitialLoad;

  set needsToCompleteInitialLoad(bool value) {
    _webViewModel.needsToCompleteInitialLoad = value;
  }

  InAppWebViewSettings? get settings => _webViewModel.settings;

  set settings(InAppWebViewSettings? value) {
    _webViewModel.settings = value;
  }

  InAppWebViewKeepAlive get keepAlive => _webViewModel.keepAlive;

  int? get windowId => _webViewModel.windowId;

  Uint8List? get screenshot => _webViewModel.screenshot;

  set screenshot(Uint8List? value) {
    _webViewModel.screenshot = value;
  }

  void updateWithValue(WebViewProvider webViewModel) {
    tabIndex = webViewModel.tabIndex;
    url = webViewModel.url;
    title = webViewModel.title;
    progress = webViewModel.progress;
    favicon = webViewModel.favicon;
    loaded = webViewModel.loaded;
    isDesktopMode = webViewModel.isDesktopMode;
    isIncognitoMode = webViewModel.isIncognitoMode;
    setJavascriptConsoleResults(webViewModel.javascriptConsoleResult);
    setJavascriptConsoleHistories(webViewModel.javascriptConsoleHistory);
    setLoadedResource(webViewModel.loadedResource);
    isSSL = webViewModel.isSSL;
    settings = webViewModel.settings;
    webViewController = webViewModel.webViewController;
    pullToRefreshController = webViewModel.pullToRefreshController;
    findInteractionController = webViewModel.findInteractionController;
  }

  static WebViewProvider? fromMap(Map<String, dynamic> model) {
    return WebViewProvider(webViewModel: WebViewModel.fromMap(model));
  }

  Map<String, dynamic>? toMap() {
    return _webViewModel.toMap();
  }
}
