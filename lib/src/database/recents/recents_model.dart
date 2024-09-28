import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RecentsModel {
  int? id;
  String authority;
  WebUri url;
  int? counts = 0;
  DateTime? createdAt;

  RecentsModel({
    this.id,
    required this.authority,
    required this.url,
    this.counts,
    this.createdAt,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'authority': authority,
      'url': url.toString(),
      'createdAt': DateTime.now().toString(),
      'counts': counts,
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
      counts: map['counts'] as int,
      createdAt: DateTime.tryParse(map['createdAt']),
    );
  }
}
