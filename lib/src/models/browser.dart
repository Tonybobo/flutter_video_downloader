import 'dart:async';

import 'package:video_downloader/src/models/browser_setting.dart';
import 'package:video_downloader/src/models/favourite.dart';
import 'package:video_downloader/src/models/web_archive.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class BrowserModel {
  final List<FavouriteModel> favourites = [];
  final List<WebViewTab> webViewTabs = [];
  final Map<String, WebArchive> webArchive = {};
  bool showTabScroller = false;
  int currentTabIndex = -1;
  BrowserSettings settings = BrowserSettings();
  late WebViewProvider currentWebViewProvider;
  DateTime lastTrySave = DateTime.now();
  Timer? timerSave;

  BrowserModel({required this.currentWebViewProvider});

  Map<String, dynamic> toMap() {
    return {
      "favourites": favourites.map((e) => e.toMap()).toList(),
      "webViewTabs": webViewTabs.map((e) => e.webViewProvider.toMap()).toList(),
      "webArchives":
          webArchive.map((key, value) => MapEntry(key, value.toMap())),
      "currentTabIndex": currentTabIndex,
      "settings": settings.toMap(),
      "currentWebViewProvider": currentWebViewProvider.toMap()
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
