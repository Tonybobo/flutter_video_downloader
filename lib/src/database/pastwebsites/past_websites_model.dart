class PastWebsitesModel {
  String id;
  String source;

  PastWebsitesModel({
    required this.id,
    required this.source
});

  Map<String , Object?> toMap(){
    var map = <String , Object?> {
      'source': source,
      '_id' : id
    };

    return map;
  }

  factory PastWebsitesModel.fromMap(Map<String , dynamic> map){
    return PastWebsitesModel(
      id: map['_id'] as String,
      source: map['source'] as String,
    );
  }

}