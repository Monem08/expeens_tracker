import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens (and migrates) the application's SQLite database.
///
/// Desktop (Linux/Windows) uses the `sqflite_common_ffi` backend.
/// Mobile (Android/iOS) and web use the default `sqflite` backend.
class AppDatabase {
  AppDatabase._();

  static Database? _db;

  static Future<Database> instance() async {
    final existing = _db;
    if (existing != null) return existing;

    final isDesktop =
        !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
    if (isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'expeens_tracker.db');
    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
    _db = db;
    return db;
  }

  @visibleForTesting
  static Future<void> reset() async {
    await _db?.close();
    _db = null;
  }

  static Future<void> _onCreate(Database db, int version) async {
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
      CREATE INDEX idx_transactions_date ON transactions(date DESC)
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
    await db.execute('''
      CREATE INDEX idx_bill_payments_bill ON bill_payments(bill_id, date DESC)
    ''');
  }
}
