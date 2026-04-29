import 'package:sqflite/sqflite.dart' hide Transaction;

import '../models/transaction.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final Database _db;

  Future<List<Transaction>> all({int? limit}) async {
    final rows = await _db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<Transaction?> byId(String id) async {
    final rows = await _db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Transaction.fromMap(rows.first);
  }

  Future<void> insert(Transaction tx) async {
    await _db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    await _db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) AS c FROM transactions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteAll() async {
    await _db.delete('transactions');
  }
}
