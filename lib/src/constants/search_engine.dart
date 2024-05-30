// ignore_for_file: constant_identifier_names

import 'package:video_downloader/src/models/search_engine.dart';

const GoogleSearchEngine = SearchEngine(
  name: "Google",
  assetIcon: 'assets/images/google_logo.webp',
  url: "https://www.google.com/",
  searchUrl: "https://www.google.com/search?q=",
);

const YahooSearchEngine = SearchEngine(
  name: "Yahoo",
  assetIcon: "assets/images/yahoo_logo.png",
  url: "https://yahoo.com/",
  searchUrl: "https://search.yahoo.com/search?p=",
);

const SearchEngines = <SearchEngine>[GoogleSearchEngine, YahooSearchEngine];
