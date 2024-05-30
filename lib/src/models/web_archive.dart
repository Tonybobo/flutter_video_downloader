import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebArchive {
  WebUri? url;
  String? title;
  Favicon? favicon;
  String? path;
  DateTime timestamp;

  WebArchive({
    this.url,
    this.title,
    this.favicon,
    this.path,
    required this.timestamp,
  });

  static WebArchive? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? WebArchive(
            url: map["url"] != null ? WebUri(map["url"]) : null,
            title: map["title"],
            path: map["path"],
            timestamp: DateTime.fromMicrosecondsSinceEpoch(map["timestamp"]),
            favicon: map["favicon"] != null
                ? Favicon(
                    url: WebUri(map["favicon"]["url"]),
                    rel: map["favicon"]["rel"],
                    width: map["favicon"]["width"],
                    height: map["favicon"]["height"],
                  )
                : null)
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "title": title,
      "favicon": favicon?.toMap(),
      "path": path,
      "timestamp": timestamp.microsecondsSinceEpoch
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
