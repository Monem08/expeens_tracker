import 'package:sqflite/sqflite.dart';

import '../models/bill.dart';

class BillRepository {
  BillRepository(this._db);

  final Database _db;

  Future<List<Bill>> all() async {
    final billRows = await _db.query('bills', orderBy: 'due_date ASC');
    if (billRows.isEmpty) return const [];
    final paymentRows = await _db.query(
      'bill_payments',
      orderBy: 'date DESC',
    );
    final paymentsByBill = <String, List<BillPayment>>{};
    for (final row in paymentRows) {
      final billId = row['bill_id']! as String;
      paymentsByBill
          .putIfAbsent(billId, () => [])
          .add(BillPayment.fromMap(row));
    }
    return billRows
        .map(
          (row) => Bill.fromMap(
            row,
            payments: paymentsByBill[row['id']] ?? const [],
          ),
        )
        .toList();
  }

  Future<Bill?> byId(String id) async {
    final rows = await _db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final paymentRows = await _db.query(
      'bill_payments',
      where: 'bill_id = ?',
      whereArgs: [id],
      orderBy: 'date DESC',
    );
    return Bill.fromMap(
      rows.first,
      payments: paymentRows.map(BillPayment.fromMap).toList(),
    );
  }

  Future<void> insert(Bill bill) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'bills',
        bill.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'bill_payments',
        where: 'bill_id = ?',
        whereArgs: [bill.id],
      );
      for (final payment in bill.paymentHistory) {
        await txn.insert('bill_payments', payment.toMap(bill.id));
      }
    });
  }

  Future<void> setAutoPay(String id, bool autoPay) async {
    await _db.update(
      'bills',
      {'auto_pay': autoPay ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    final result = await _db.rawQuery('SELECT COUNT(*) AS c FROM bills');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> delete(String id) async {
    await _db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    await _db.delete('bills');
  }
}
