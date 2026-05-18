import 'dart:async';

import 'sqlite_database.dart';

enum DataType { int, text, real, blob, num }

extension DataTypeExt on DataType {
  String get typeStr {
    switch (this) {
      case DataType.int:
        return 'INTEGER';
      case DataType.text:
        return 'TEXT';
      case DataType.real:
        return 'REAL';
      case DataType.blob:
        return 'BLOB';
      case DataType.num:
        return 'NUMERIC';
    }
  }
}

class DataColumn {
  final String name;
  final DataType type;
  final bool isPrimary;
  final bool notNull;

  DataColumn({
    required this.name,
    required this.type,
    this.isPrimary = false,
    this.notNull = false,
  });

  String get create =>
      '''$name ${type.typeStr} ${isPrimary ? 'PRIMARY KEY NOT NULL' : ''} ${isPrimary ? '' : notNull ? 'NOT NULL' : ''}''';
}

abstract class DAO {
  final SQLiteDatabase db;

  DAO(this.db);

  String get tableName;

  String get createQuery => '''CREATE TABLE IF NOT EXISTS $tableName (
  ${columns.map((e) => e.create).join(',')}
)''';

  var _isCreated = false;

  Future<void> create() async {
    await db.create();
    if (!_isCreated) {
      await db.database.execute(createQuery);
      _isCreated = true;
    }
  }

  Future close() async {
    await db.close();
  }

  Future<T> execute<T>(Future<T> Function() executable) {
    return db.execute<T>(executable, create: create);
  }

  List<DataColumn> get columns;

  List<String> get columnsWhere => [...columns.map((e) => e.name)];
}
