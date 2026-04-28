import 'package:expeens_tracker/data/bill_repository.dart';
import 'package:expeens_tracker/data/seed.dart';
import 'package:expeens_tracker/data/transaction_repository.dart';
import 'package:expeens_tracker/models/bill.dart';
import 'package:expeens_tracker/models/category.dart';
import 'package:expeens_tracker/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

Future<Database> _openTestDb() {
  return databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            date INTEGER NOT NULL,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE bills (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            biller TEXT NOT NULL,
            amount REAL NOT NULL,
            due_date INTEGER NOT NULL,
            status TEXT NOT NULL,
            icon_kind TEXT NOT NULL,
            account_last4 TEXT,
            auto_pay INTEGER NOT NULL DEFAULT 0,
            billing_period_start INTEGER,
            billing_period_end INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE bill_payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bill_id TEXT NOT NULL,
            amount REAL NOT NULL,
            date INTEGER NOT NULL,
            succeeded INTEGER NOT NULL,
            FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
          )
        ''');
      },
    ),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TransactionRepository', () {
    late Database db;
    late TransactionRepository repo;

    setUp(() async {
      db = await _openTestDb();
      repo = TransactionRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('round-trips all fields via insert/all', () async {
      final tx = Transaction(
        id: 'x1',
        title: 'Coffee',
        category: ExpenseCategory.coffee,
        amount: -4.50,
        date: DateTime(2026, 1, 15, 9, 30),
        note: 'Morning run',
      );
      await repo.insert(tx);

      final all = await repo.all();
      expect(all, hasLength(1));
      final got = all.single;
      expect(got.id, 'x1');
      expect(got.title, 'Coffee');
      expect(got.category, ExpenseCategory.coffee);
      expect(got.amount, -4.50);
      expect(got.date, DateTime(2026, 1, 15, 9, 30));
      expect(got.note, 'Morning run');
    });

    test('orders by date desc and counts correctly', () async {
      await repo.insert(
        Transaction(
          id: 'a',
          title: 'Old',
          category: ExpenseCategory.food,
          amount: -10,
          date: DateTime(2025, 1, 1),
        ),
      );
      await repo.insert(
        Transaction(
          id: 'b',
          title: 'New',
          category: ExpenseCategory.food,
          amount: -10,
          date: DateTime(2026, 1, 1),
        ),
      );
      final all = await repo.all();
      expect(all.map((t) => t.id).toList(), ['b', 'a']);
      expect(await repo.count(), 2);
    });
  });

  group('BillRepository', () {
    late Database db;
    late BillRepository repo;

    setUp(() async {
      db = await _openTestDb();
      repo = BillRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('persists bill + payment history', () async {
      final bill = Bill(
        id: 'b1',
        name: 'Electricity',
        biller: 'City Grid',
        amount: 142.50,
        dueDate: DateTime(2026, 5, 1),
        status: BillStatus.priority,
        iconKind: BillIconKind.bolt,
        accountLast4: '8842',
        autoPay: true,
        billingPeriodStart: DateTime(2026, 4, 1),
        billingPeriodEnd: DateTime(2026, 4, 30),
        paymentHistory: [
          BillPayment(
            amount: 138.20,
            date: DateTime(2026, 4, 3),
            succeeded: true,
          ),
        ],
      );
      await repo.insert(bill);

      final got = await repo.byId('b1');
      expect(got, isNotNull);
      expect(got!.name, 'Electricity');
      expect(got.autoPay, true);
      expect(got.iconKind, BillIconKind.bolt);
      expect(got.paymentHistory, hasLength(1));
      expect(got.paymentHistory.single.amount, 138.20);
    });

    test('setAutoPay toggles field', () async {
      await repo.insert(
        Bill(
          id: 'b2',
          name: 'Rent',
          biller: 'Palmwood',
          amount: 1200,
          dueDate: DateTime(2026, 5, 1),
          status: BillStatus.scheduled,
          iconKind: BillIconKind.apartment,
        ),
      );
      await repo.setAutoPay('b2', true);
      final got = await repo.byId('b2');
      expect(got!.autoPay, true);
    });
  });

  group('seedIfNeeded', () {
    test('seeds only when empty', () async {
      final db = await _openTestDb();
      addTearDown(db.close);
      final tx = TransactionRepository(db);
      final bill = BillRepository(db);

      await seedIfNeeded(transactions: tx, bills: bill);
      final firstTxCount = await tx.count();
      final firstBillCount = await bill.count();
      expect(firstTxCount, greaterThan(0));
      expect(firstBillCount, greaterThan(0));

      await seedIfNeeded(transactions: tx, bills: bill);
      expect(await tx.count(), firstTxCount);
      expect(await bill.count(), firstBillCount);
    });
  });
}
