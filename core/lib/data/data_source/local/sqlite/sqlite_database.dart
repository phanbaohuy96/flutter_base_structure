import 'dart:async';

import 'package:sqflite/sqflite.dart';

abstract class SQLiteDatabase {
  bool get isOpen;
  Database get database;

  Future<Database?> create({OnDatabaseCreateFn? onCreate});

  int get executingCount => _executingCount;

  var _executingCount = 0;

  Future<T> execute<T>(
    Future<T> Function() executable, {
    Future<void> Function()? create,
  }) async {
    await create?.call();

    _executingCount++;
    final result = await executable();
    _executingCount--;

    await close();

    return result;
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return database.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return database.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<void> close() async {
    if (isOpen && executingCount == 0) {
      await database.close();
    }
  }
}
