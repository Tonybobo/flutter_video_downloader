class SearchEngine {
  final String name;
  final String assetIcon;
  final String url;
  final String searchUrl;

  const SearchEngine(
      {required this.name,
      required this.assetIcon,
      required this.url,
      required this.searchUrl});

  static SearchEngine? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? SearchEngine(
            name: map["name"],
            assetIcon: map["assetIcon"],
            url: map["url"],
            searchUrl: map["searchUrl"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "assetIcon": assetIcon,
      "url": url,
      "searchUrl": searchUrl
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
