import 'package:video_downloader/src/constants/search_engine.dart';
import 'package:video_downloader/src/models/search_engine.dart';

class BrowserSettings {
  SearchEngine searchEngine;
  bool homePageEnabled;
  String customUrlHomePage;
  bool debuggingEnabled;

  BrowserSettings({
    this.searchEngine = GoogleSearchEngine,
    this.homePageEnabled = true,
    this.customUrlHomePage = "https://www.google.com",
    this.debuggingEnabled = false,
  });

  BrowserSettings copy() {
    return BrowserSettings(
      searchEngine: searchEngine,
      homePageEnabled: homePageEnabled,
      customUrlHomePage: customUrlHomePage,
      debuggingEnabled: debuggingEnabled,
    );
  }

  static BrowserSettings? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? BrowserSettings(
            searchEngine: SearchEngines[map["searchEngineIndex"]],
            homePageEnabled: map["homePageenabled"],
            customUrlHomePage: map["customUrlHomePage"],
            debuggingEnabled: map["debuggingEnabled"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "searchEngineIndex": SearchEngines.indexOf(searchEngine),
      "homePageenabled": homePageEnabled,
      "customUrlHomePage": customUrlHomePage,
      "debuggingEnabled": debuggingEnabled,
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
