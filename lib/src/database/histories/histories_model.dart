import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HistoriesModel {
  int? id;
  String? title;
  WebUri url;
  DateTime? createdAt;

  HistoriesModel({
    this.id,
    this.title,
    required this.url,
    this.createdAt,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'title': title ?? url.toString(),
      'url': url.toString(),
      'createdAt': DateTime.now().toString()
    };
    if (id != null) {
      map['_id'] = id;
    }
    return map;
  }

  factory HistoriesModel.fromMap(Map<String, dynamic> map) {
    return HistoriesModel(
        id: map['_id'] as int?,
        title: map['title'] as String,
        url: WebUri(map['url']),
        createdAt: DateTime.tryParse(map['createdAt']));
  }
}
