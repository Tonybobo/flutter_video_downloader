import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_downloader/src/models/browser.dart';
import 'package:video_downloader/src/models/browser_setting.dart';
import 'package:video_downloader/src/models/favourite.dart';
import 'package:video_downloader/src/models/web_archive.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';
import 'package:collection/collection.dart';

class BrowserProvider extends ChangeNotifier {
  final BrowserModel _browserModel = BrowserModel(
    currentWebViewProvider: WebViewProvider(),
  );

  bool get showTabScroller => _browserModel.showTabScroller;

  set showTabScroller(bool value) {
    if (value != _browserModel.showTabScroller) {
      _browserModel.showTabScroller = value;
      notifyListeners();
    }
  }

  UnmodifiableListView<WebViewTab> get webViewTabs =>
      UnmodifiableListView(_browserModel.webViewTabs);

  UnmodifiableListView<FavouriteModel> get favourites =>
      UnmodifiableListView(_browserModel.favourites);

  UnmodifiableMapView<String, WebArchive> get webArchive =>
      UnmodifiableMapView(_browserModel.webArchive);

  void addTab(WebViewTab webViewTab) {
    _browserModel.webViewTabs.add(webViewTab);
    _browserModel.currentTabIndex = _browserModel.webViewTabs.length - 1;

    webViewTab.webViewProvider.tabIndex = _browserModel.currentTabIndex;

    _browserModel.currentWebViewProvider
        .updateWithValue(webViewTab.webViewProvider);

    notifyListeners();
  }

  void addTabs(List<WebViewTab> webViewTabs) {
    _browserModel.webViewTabs.addAll(webViewTabs);
    _browserModel.currentTabIndex = _browserModel.webViewTabs.length - 1;

    if (_browserModel.currentTabIndex >= 0) {
      _browserModel.currentWebViewProvider
          .updateWithValue(webViewTabs.last.webViewProvider);
    }

    notifyListeners();
  }

  void closeTab(int index) {
    final webViewTab = _browserModel.webViewTabs[index];
    _browserModel.webViewTabs.removeAt(index);
    InAppWebViewController.disposeKeepAlive(
        webViewTab.webViewProvider.keepAlive);

    _browserModel.currentTabIndex = _browserModel.webViewTabs.length - 1;

    for (int i = index; i < _browserModel.webViewTabs.length; i++) {
      _browserModel.webViewTabs[i].webViewProvider.tabIndex = i;
    }

    if (_browserModel.currentTabIndex >= 0) {
      _browserModel.currentWebViewProvider.updateWithValue(_browserModel
          .webViewTabs[_browserModel.currentTabIndex].webViewProvider);
    } else {
      _browserModel.currentWebViewProvider.updateWithValue(
        WebViewProvider(
          javascriptConsoleResult: [],
          javascriptConsoleHistory: [],
          loadedResources: [],
        ),
      );
    }
  }

  void showTab(int index) {
    if (_browserModel.currentTabIndex != index) {
      _browserModel.currentTabIndex = index;
    }
    _browserModel.currentWebViewProvider
        .updateWithValue(_browserModel.webViewTabs[index].webViewProvider);

    notifyListeners();
  }

  void closeAllTabs() {
    for (final webViewTab in _browserModel.webViewTabs) {
      InAppWebViewController.disposeKeepAlive(
          webViewTab.webViewProvider.keepAlive);
    }
    _browserModel.webViewTabs.clear();
    _browserModel.currentTabIndex = -1;
    _browserModel.currentWebViewProvider.updateWithValue(
      WebViewProvider(
        javascriptConsoleResult: [],
        javascriptConsoleHistory: [],
        loadedResources: [],
      ),
    );

    notifyListeners();
  }

  int getCurrentTabIndex() {
    return _browserModel.currentTabIndex;
  }

  WebViewTab? getCurrentTab() {
    return _browserModel.currentTabIndex >= 0
        ? _browserModel.webViewTabs[_browserModel.currentTabIndex]
        : null;
  }

  bool containsFavourite(FavouriteModel favourite) {
    return _browserModel.favourites.contains(favourite) ||
        _browserModel.favourites
                .map((e) => e)
                .firstWhereOrNull((element) => element.url == favourite.url) !=
            null;
  }

  void addFavourite(FavouriteModel favourite) {
    _browserModel.favourites.add(favourite);
    notifyListeners();
  }

  void addFavourites(List<FavouriteModel> favourites) {
    _browserModel.favourites.addAll(favourites);
    notifyListeners();
  }

  void clearFavourites() {
    _browserModel.favourites.clear();
    notifyListeners();
  }

  void removeFavourite(FavouriteModel favourite) {
    if (!_browserModel.favourites.remove(favourite)) {
      var favToRemove = _browserModel.favourites
          .map((e) => e)
          .firstWhereOrNull((element) => element.url == favourite.url);

      _browserModel.favourites.remove(favToRemove);
    }
    notifyListeners();
  }

  void addWebArchive(String url, WebArchive webArchive) {
    _browserModel.webArchive.putIfAbsent(url, () => webArchive);
    notifyListeners();
  }

  void addWebArchives(Map<String, WebArchive> webArchives) {
    _browserModel.webArchive.addAll(webArchives);
    notifyListeners();
  }

  void removeWebArchive(WebArchive webArchive) {
    final path = webArchive.path;
    if (path != null) {
      final webArchiveFile = File(path);
      try {
        webArchiveFile.deleteSync();
      } finally {
        _browserModel.webArchive.remove(webArchive.url.toString());
      }
      notifyListeners();
    }
  }

  void clearWebArchives() {
    _browserModel.webArchive.forEach((key, webArchive) {
      final path = webArchive.path;

      if (path != null) {
        final webArchiveFile = File(path);
        try {
          webArchiveFile.deleteSync();
        } finally {
          _browserModel.webArchive.remove(key);
        }
      }
    });
    notifyListeners();
  }

  BrowserSettings getSettings() => _browserModel.settings.copy();

  void updateSettings(BrowserSettings settings) {
    _browserModel.settings = settings;
    notifyListeners();
  }

  void setCurrentWebViewProvider(WebViewProvider webViewProvider) {
    _browserModel.currentWebViewProvider = webViewProvider;
  }

  Future<void> save() async {
    _browserModel.timerSave?.cancel();

    if (DateTime.now().difference(_browserModel.lastTrySave) >=
        const Duration(milliseconds: 400)) {
      _browserModel.lastTrySave = DateTime.now();
      await flush();
    } else {
      _browserModel.lastTrySave = DateTime.now();
      _browserModel.timerSave = Timer(const Duration(milliseconds: 500), () {
        save();
      });
    }
  }

  Future<void> flush() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("browser", json.encode(_browserModel.toJson()));
  }

  Future<void> restore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> browserData;

    try {
      String? source = prefs.getString("browser");
      if (source != null) {
        browserData = await json.decode(source);

        clearFavourites();
        closeAllTabs();
        clearWebArchives();

        List<Map<String, dynamic>> favouriteList =
            browserData["favourites"]?.cast<Map<String, dynamic>>() ?? [];

        List<FavouriteModel> favourites =
            favouriteList.map((e) => FavouriteModel.fromMap(e)!).toList();

        Map<String, dynamic> webArchiveMap =
            browserData["webArchives"]?.cast<String, dynamic>() ?? {};

        Map<String, WebArchive> webArchives = webArchiveMap.map((key, value) =>
            MapEntry(key, WebArchive.fromMap(value?.cast<String, dynamic>())!));

        BrowserSettings settings = BrowserSettings.fromMap(
                browserData["settings"]?.cast<Map<String, dynamic>>()) ??
            BrowserSettings();

        List<Map<String, dynamic>> webViewTabList =
            browserData["webViewTabs"]?.cast<Map<String, dynamic>>() ?? [];

        List<WebViewTab> webViewTabs = webViewTabList
            .map((e) => WebViewTab(
                key: GlobalKey(), webViewProvider: WebViewProvider.fromMap(e)!))
            .toList();

        webViewTabs.sort((a, b) =>
            a.webViewProvider.tabIndex!.compareTo(b.webViewProvider.tabIndex!));

        addFavourites(favourites);
        addWebArchives(webArchives);
        updateSettings(settings);
        addTabs(webViewTabs);

        int currentTabIndex =
            browserData["currentTabIndex"] ?? _browserModel.currentTabIndex;
        currentTabIndex =
            min(currentTabIndex, _browserModel.webViewTabs.length - 1);

        if (currentTabIndex >= 0) {
          showTab(currentTabIndex);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }
}
