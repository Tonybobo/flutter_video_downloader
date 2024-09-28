class RecentsTable {
  static const tableName = 'recents';

  static const columnId = '_id';

  static const columnAuthority = 'authority';

  static const columnUrl = 'url';

  static const columnCount = 'counts';

  static const columnCreatedAt = 'createdAt';

  static const onCreate = '''
      CREATE TABLE IF NOT EXISTS $tableName(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnAuthority TEXT NOT NULL UNIQUE,
        $columnUrl TEXT NOT NULL,
        $columnCount INTEGER NOT NULL DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL
      ) ;
      CREATE INDEX url_authority ON recents (authority);
    ''';
}
