import 'package:expeens_tracker/data/transaction_stats.dart';
import 'package:expeens_tracker/models/category.dart';
import 'package:expeens_tracker/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String id,
  required double amount,
  required DateTime date,
  ExpenseCategory category = ExpenseCategory.food,
}) {
  return Transaction(
    id: id,
    title: id,
    category: category,
    amount: amount,
    date: date,
  );
}

void main() {
  group('TransactionStats.totalBalance', () {
    test('sums signed amounts', () {
      final txs = [
        _tx(id: 'a', amount: 100, date: DateTime(2026, 4, 1)),
        _tx(id: 'b', amount: -30, date: DateTime(2026, 4, 2)),
        _tx(id: 'c', amount: -10.5, date: DateTime(2026, 4, 3)),
      ];
      expect(TransactionStats.totalBalance(txs), closeTo(59.5, 1e-9));
    });

    test('returns 0 for empty list', () {
      expect(TransactionStats.totalBalance(const []), 0);
    });
  });

  group('TransactionStats.monthlyChangePct', () {
    test('% change vs last month uses absolute denominator', () {
      final now = DateTime(2026, 4, 28);
      final txs = [
        // March: net = 100
        _tx(id: 'm1', amount: 200, date: DateTime(2026, 3, 5)),
        _tx(id: 'm2', amount: -100, date: DateTime(2026, 3, 20)),
        // April: net = 150 → +50% vs March's 100
        _tx(id: 'a1', amount: 200, date: DateTime(2026, 4, 1)),
        _tx(id: 'a2', amount: -50, date: DateTime(2026, 4, 27)),
      ];
      expect(
        TransactionStats.monthlyChangePct(txs, now),
        closeTo(50, 1e-9),
      );
    });

    test('falls back to profit margin when last month is empty', () {
      final now = DateTime(2026, 4, 28);
      final txs = [
        _tx(id: 'a1', amount: 1000, date: DateTime(2026, 4, 1)),
        _tx(id: 'a2', amount: -250, date: DateTime(2026, 4, 27)),
      ];
      // net 750, income 1000 → 75%
      expect(
        TransactionStats.monthlyChangePct(txs, now),
        closeTo(75, 1e-9),
      );
    });

    test('returns 0 when there is no data at all', () {
      expect(
        TransactionStats.monthlyChangePct(const [], DateTime(2026, 4, 28)),
        0,
      );
    });

    test('negative result when this month is worse than last', () {
      final now = DateTime(2026, 4, 28);
      final txs = [
        _tx(id: 'm1', amount: 200, date: DateTime(2026, 3, 5)),
        _tx(id: 'a1', amount: 100, date: DateTime(2026, 4, 5)),
      ];
      // (100 - 200) / 200 = -50%
      expect(
        TransactionStats.monthlyChangePct(txs, now),
        closeTo(-50, 1e-9),
      );
    });
  });

  group('TransactionStats.weeklySpending', () {
    test('buckets expenses by Mon..Sun for the current week', () {
      // Wed Apr 22 2026 → Mon = Apr 20.
      final now = DateTime(2026, 4, 22);
      final txs = [
        _tx(id: 'mon', amount: -10, date: DateTime(2026, 4, 20, 9)),
        _tx(id: 'wed1', amount: -5, date: DateTime(2026, 4, 22, 8)),
        _tx(id: 'wed2', amount: -7.5, date: DateTime(2026, 4, 22, 19)),
        // income should be ignored
        _tx(id: 'wed_inc', amount: 1000, date: DateTime(2026, 4, 22, 9)),
        // outside the current week
        _tx(id: 'prev_sun', amount: -50, date: DateTime(2026, 4, 19)),
        _tx(id: 'next_mon', amount: -50, date: DateTime(2026, 4, 27)),
      ];
      final result = TransactionStats.weeklySpending(txs, now);
      expect(result, [10, 0, 12.5, 0, 0, 0, 0]);
    });

    test('returns all zeros when no expenses fall in the current week', () {
      final now = DateTime(2026, 4, 22);
      final txs = [
        _tx(id: 'old', amount: -50, date: DateTime(2026, 1, 1)),
      ];
      expect(
        TransactionStats.weeklySpending(txs, now),
        [0, 0, 0, 0, 0, 0, 0],
      );
    });
  });

  group('TransactionStats.peakIndex', () {
    test('returns index of highest non-zero bucket', () {
      expect(TransactionStats.peakIndex([1, 5, 2, 5, 0, 0, 3]), 1);
    });

    test('returns null when all buckets are zero', () {
      expect(TransactionStats.peakIndex([0, 0, 0, 0, 0, 0, 0]), isNull);
    });
  });
}
