import 'package:expeens_tracker/data/bill_repository.dart';
import 'package:expeens_tracker/data/transaction_repository.dart';
import 'package:expeens_tracker/models/category.dart';
import 'package:expeens_tracker/models/transaction.dart';
import 'package:expeens_tracker/screens/home_screen.dart';
import 'package:expeens_tracker/state/bill_store.dart';
import 'package:expeens_tracker/state/transaction_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // Use the no-isolate factory so DB work runs on the flutter test loop
    // instead of a background isolate (which can stall pumpAndSettle).
    databaseFactory = databaseFactoryFfiNoIsolate;
    // Avoid HTTP calls to fonts.google.com during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HomeScreen renders transactions persisted in the store', (
    tester,
  ) async {
    final db = await databaseFactory.openDatabase(
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
    addTearDown(db.close);

    final txRepo = TransactionRepository(db);
    final billRepo = BillRepository(db);

    // Insert a single transaction directly so we can assert it renders
    // without depending on any application-level seed data.
    await txRepo.insert(
      Transaction(
        id: 't-test',
        title: 'Test Coffee',
        category: ExpenseCategory.coffee,
        amount: -4.25,
        date: DateTime.now(),
      ),
    );

    final txStore = TransactionStore(txRepo);
    final billStore = BillStore(billRepo);
    await txStore.load();
    await billStore.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: txStore),
          ChangeNotifierProvider.value(value: billStore),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('MintyExpense'), findsOneWidget);
    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Test Coffee'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(find.text('Test Coffee'), findsOneWidget);
  });

  testWidgets('HomeScreen renders empty state with no transactions', (
    tester,
  ) async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
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
    addTearDown(db.close);

    final txStore = TransactionStore(TransactionRepository(db));
    final billStore = BillStore(BillRepository(db));
    await txStore.load();
    await billStore.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: txStore),
          ChangeNotifierProvider.value(value: billStore),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // With an empty database the balance card shows $0.00 and a 0.0% change.
    expect(find.text('\$0.00'), findsOneWidget);
    expect(find.text('0.0%'), findsOneWidget);
  });
}
