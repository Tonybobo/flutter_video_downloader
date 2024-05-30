import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_downloader/src/models/web_view.dart';

class WebViewProvider extends ChangeNotifier {
  WebViewModel _webViewModel = WebViewModel(
    javascriptConsoleHistory: <String>[],
    javascriptConsoleResult: <Widget>[],
    loadedResource: <LoadedResource>[],
  );

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

  UnmodifiableListView<Widget> get javascriptConsoleResults =>
      UnmodifiableListView(_webViewModel.javascriptConsoleResult);

  set javascriptConsoleResults(List<Widget> value) {
    if (!listEquals(value, _webViewModel.javascriptConsoleResult)) {
      _webViewModel.javascriptConsoleResult = value;
      notifyListeners();
    }
  }

  void addJavascriptConsoleResults(Widget value) {
    _webViewModel.javascriptConsoleResult.add(value);
    notifyListeners();
  }

  UnmodifiableListView<LoadedResource> get loadedResource =>
      UnmodifiableListView(_webViewModel.loadedResource);

  set loadedResource(List<LoadedResource> value) {
    if (!listEquals(value, _webViewModel.loadedResource)) {
      _webViewModel.loadedResource = value;
      notifyListeners();
    }
  }

  void addLoadedResource(LoadedResource value) {
    _webViewModel.loadedResource.add(value);
    notifyListeners();
  }

  bool get isSSL => _webViewModel.isSSL;

  set isSSL(bool value) {
    if (value != _webViewModel.isSSL) {
      _webViewModel.isSSL = value;
      notifyListeners();
    }
  }

  void updateWithValue(WebViewModel webViewModel) {
    _webViewModel = WebViewModel(
        tabIndex: webViewModel.tabIndex,
        url: webViewModel.url,
        title: webViewModel.title,
        favicon: webViewModel.favicon,
        progress: webViewModel.progress,
        loaded: webViewModel.loaded,
        isDesktopMode: webViewModel.isDesktopMode,
        isIncognitoMode: webViewModel.isIncognitoMode,
        javascriptConsoleResult: webViewModel.javascriptConsoleResult,
        javascriptConsoleHistory: webViewModel.javascriptConsoleHistory,
        loadedResource: webViewModel.loadedResource,
        isSSL: webViewModel.isSSL,
        settings: webViewModel.settings,
        webViewController: webViewModel.webViewController,
        pullToRefreshController: webViewModel.pullToRefreshController,
        findInteractionController: webViewModel.findInteractionController);
  }

  Map<String, dynamic>? toMap() {
    return _webViewModel.toMap();
  }
}
