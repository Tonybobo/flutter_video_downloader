class HistoriesTable {
  static const tableName = 'histories';

  static const columnId = '_id';

  static const columnTitle = 'title';

  static const columnUrl = 'url';

  static const columnCreatedAt = 'createdAt';

  static const onCreate = '''
     CREATE TABLE IF NOT EXISTS $tableName(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT ,
        $columnUrl TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL
     )
    ''';
}
