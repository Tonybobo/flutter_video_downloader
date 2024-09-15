class QueryConditions {
  int? limit;
  int? offset;
  String? orderBy;

  QueryConditions({limit, offset, orderBy}) {
    this.limit = limit ?? 10;
    this.offset = offset ?? 0;
    this.orderBy = orderBy ?? 'createdAt DESC';
  }
}
