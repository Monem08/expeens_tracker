import 'package:expeens_tracker/data/transaction_filters.dart';
import 'package:expeens_tracker/models/category.dart';
import 'package:expeens_tracker/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String id,
  required String title,
  required ExpenseCategory cat,
  required double amount,
  required DateTime date,
  String? note,
}) {
  return Transaction(
    id: id,
    title: title,
    category: cat,
    amount: amount,
    date: date,
    note: note,
  );
}

void main() {
  group('TransactionFilters.search', () {
    final txs = [
      _tx(
        id: '1',
        title: 'Coffee',
        cat: ExpenseCategory.food,
        amount: -5,
        date: DateTime(2026, 3, 1),
      ),
      _tx(
        id: '2',
        title: 'Gas',
        cat: ExpenseCategory.transport,
        amount: -40,
        date: DateTime(2026, 3, 2),
        note: 'Shell station',
      ),
      _tx(
        id: '3',
        title: 'Salary',
        cat: ExpenseCategory.income,
        amount: 2000,
        date: DateTime(2026, 3, 3),
      ),
    ];

    test('empty query returns list unchanged', () {
      expect(TransactionFilters.search(txs, ''), txs);
    });

    test('matches title case-insensitively', () {
      final out = TransactionFilters.search(txs, 'coffee');
      expect(out, hasLength(1));
      expect(out.first.id, '1');
    });

    test('matches notes', () {
      final out = TransactionFilters.search(txs, 'shell');
      expect(out.map((t) => t.id), ['2']);
    });

    test('matches category label', () {
      final out = TransactionFilters.search(txs, 'income');
      expect(out.map((t) => t.id), ['3']);
    });
  });

  group('TransactionFilters.inMonth', () {
    test('keeps only same-month entries', () {
      final now = DateTime(2026, 3, 15);
      final txs = [
        _tx(
          id: '1',
          title: 'a',
          cat: ExpenseCategory.food,
          amount: -1,
          date: DateTime(2026, 2, 27),
        ),
        _tx(
          id: '2',
          title: 'b',
          cat: ExpenseCategory.food,
          amount: -1,
          date: DateTime(2026, 3, 2),
        ),
        _tx(
          id: '3',
          title: 'c',
          cat: ExpenseCategory.food,
          amount: -1,
          date: DateTime(2026, 3, 31),
        ),
      ];
      final out = TransactionFilters.inMonth(txs, now);
      expect(out.map((t) => t.id), ['2', '3']);
    });
  });

  group('TransactionFilters.byCategory', () {
    test('null returns list unchanged', () {
      final txs = [
        _tx(
          id: '1',
          title: 'a',
          cat: ExpenseCategory.food,
          amount: -1,
          date: DateTime(2026, 3, 1),
        ),
      ];
      expect(TransactionFilters.byCategory(txs, null), txs);
    });

    test('filters to category', () {
      final txs = [
        _tx(
          id: '1',
          title: 'a',
          cat: ExpenseCategory.food,
          amount: -1,
          date: DateTime(2026, 3, 1),
        ),
        _tx(
          id: '2',
          title: 'b',
          cat: ExpenseCategory.transport,
          amount: -1,
          date: DateTime(2026, 3, 2),
        ),
      ];
      final out = TransactionFilters.byCategory(txs, ExpenseCategory.food);
      expect(out.map((t) => t.id), ['1']);
    });
  });

  group('TransactionFilters.sortedByAmountDesc', () {
    test('sorts by absolute amount descending', () {
      final txs = [
        _tx(
          id: '1',
          title: 'small',
          cat: ExpenseCategory.food,
          amount: -5,
          date: DateTime(2026, 3, 1),
        ),
        _tx(
          id: '2',
          title: 'big income',
          cat: ExpenseCategory.income,
          amount: 2000,
          date: DateTime(2026, 3, 2),
        ),
        _tx(
          id: '3',
          title: 'mid expense',
          cat: ExpenseCategory.food,
          amount: -100,
          date: DateTime(2026, 3, 3),
        ),
      ];
      final out = TransactionFilters.sortedByAmountDesc(txs);
      expect(out.map((t) => t.id), ['2', '3', '1']);
    });

    test('does not mutate input', () {
      final txs = [
        _tx(
          id: '1',
          title: 'a',
          cat: ExpenseCategory.food,
          amount: -5,
          date: DateTime(2026, 3, 1),
        ),
        _tx(
          id: '2',
          title: 'b',
          cat: ExpenseCategory.food,
          amount: -100,
          date: DateTime(2026, 3, 2),
        ),
      ];
      TransactionFilters.sortedByAmountDesc(txs);
      expect(txs.map((t) => t.id), ['1', '2']);
    });
  });
}
