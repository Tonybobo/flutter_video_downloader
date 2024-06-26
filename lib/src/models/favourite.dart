import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FavouriteModel {
  WebUri? url;
  String? title;
  Favicon? favicon;

  FavouriteModel(
      {required this.url, required this.title, required this.favicon});

  static FavouriteModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? FavouriteModel(
            url: map['url'] != null ? WebUri(map["url"]) : null,
            title: map["title"],
            favicon: map["favicon"] != null
                ? Favicon(
                    url: WebUri(map["favicon"]["url"]),
                    rel: map["favicon"]["rel"],
                    width: map["favicon"]["width"],
                    height: map["favicon"]["height"])
                : null)
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "title": title,
      "favicon": favicon?.toMap()
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
