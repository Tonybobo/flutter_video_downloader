class PastWebsiteTable {
  static const tableName = 'pastWebsites';

  static const columnId = '_id';

  static const columnSource = 'source';

  static const onCreate = '''
     CREATE TABLE IF NOT EXISTS $tableName(
        $columnId TEXT PRIMARY KEY,
        $columnSource TEXT NULL
     )
    ''';

}