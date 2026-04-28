import 'package:expeens_tracker/data/bill_repository.dart';
import 'package:expeens_tracker/data/seed.dart';
import 'package:expeens_tracker/data/transaction_repository.dart';
import 'package:expeens_tracker/screens/home_screen.dart';
import 'package:expeens_tracker/state/bill_store.dart';
import 'package:expeens_tracker/state/transaction_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // Use the no-isolate factory so DB work runs on the flutter test loop
    // instead of a background isolate (which can stall pumpAndSettle).
    databaseFactory = databaseFactoryFfiNoIsolate;
    // Avoid HTTP calls to fonts.google.com during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HomeScreen renders seeded data', (tester) async {
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
    await seedIfNeeded(transactions: txRepo, bills: billRepo);

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
    // Scroll the recent-transactions list into view and verify seeded
    // transaction titles were loaded from the database via the store.
    await tester.dragUntilVisible(
      find.text('Apple Store'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(find.text('Apple Store'), findsOneWidget);
  });
}
