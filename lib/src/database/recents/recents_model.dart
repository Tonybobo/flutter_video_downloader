import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RecentsModel {
  int? id;
  String authority;
  WebUri url;
  int count;
  DateTime? createdAt;

  RecentsModel({
    this.id,
    required this.authority,
    required this.url,
    required this.count,
    this.createdAt,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'authority': authority,
      'url': url.toString(),
      'count': count,
      'createdAt': DateTime.now().toString(),
    };
    if (id != null) {
      map['_id'] = id;
    }

    return map;
  }

  factory RecentsModel.fromMap(Map<String, dynamic> map) {
    return RecentsModel(
      id: map['_id'] as int?,
      authority: map['authority'] as String,
      url: WebUri(map['url']),
      count: map['count'] as int,
      createdAt: DateTime.tryParse(map['createdAt']),
    );
  }
}
