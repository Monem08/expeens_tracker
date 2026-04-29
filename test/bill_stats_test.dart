import 'package:expeens_tracker/data/bill_stats.dart';
import 'package:expeens_tracker/models/bill.dart';
import 'package:flutter_test/flutter_test.dart';

Bill _bill({
  required String id,
  required double amount,
  required DateTime dueDate,
  BillStatus status = BillStatus.upcoming,
  bool autoPay = false,
}) {
  return Bill(
    id: id,
    name: id,
    biller: 'biller',
    amount: amount,
    dueDate: dueDate,
    status: status,
    iconKind: BillIconKind.generic,
    autoPay: autoPay,
  );
}

void main() {
  final now = DateTime(2026, 4, 15);

  group('BillStats.totalThisMonth', () {
    test('sums only bills due in the same calendar month as now', () {
      final bills = [
        _bill(id: 'a', amount: 100, dueDate: DateTime(2026, 4, 1)),
        _bill(id: 'b', amount: 200, dueDate: DateTime(2026, 4, 30)),
        _bill(id: 'c', amount: 999, dueDate: DateTime(2026, 3, 31)),
        _bill(id: 'd', amount: 999, dueDate: DateTime(2026, 5, 1)),
      ];
      expect(BillStats.totalThisMonth(bills, now), 300);
    });

    test('returns 0 when no bills fall in the current month', () {
      expect(BillStats.totalThisMonth(const [], now), 0);
    });
  });

  group('BillStats.paidThisMonth', () {
    test('only counts bills with status=paid due this month', () {
      final bills = [
        _bill(
          id: 'a',
          amount: 100,
          dueDate: DateTime(2026, 4, 1),
          status: BillStatus.paid,
        ),
        _bill(
          id: 'b',
          amount: 200,
          dueDate: DateTime(2026, 4, 30),
          status: BillStatus.upcoming,
        ),
        _bill(
          id: 'c',
          amount: 500,
          dueDate: DateTime(2026, 3, 1),
          status: BillStatus.paid,
        ),
      ];
      expect(BillStats.paidThisMonth(bills, now), 100);
    });
  });

  group('BillStats.remainingThisMonth', () {
    test('total - paid', () {
      final bills = [
        _bill(
          id: 'a',
          amount: 100,
          dueDate: DateTime(2026, 4, 1),
          status: BillStatus.paid,
        ),
        _bill(
          id: 'b',
          amount: 250,
          dueDate: DateTime(2026, 4, 20),
          status: BillStatus.upcoming,
        ),
      ];
      expect(BillStats.remainingThisMonth(bills, now), 250);
    });

    test('clamps to zero (never negative)', () {
      // Defensive: paid > total shouldn't happen, but if it did the UI
      // shouldn't render a negative remaining.
      final bills = [
        _bill(
          id: 'a',
          amount: -50,
          dueDate: DateTime(2026, 4, 1),
          status: BillStatus.paid,
        ),
      ];
      expect(BillStats.remainingThisMonth(bills, now), 0);
    });
  });

  group('BillStats.autoPayCountThisMonth', () {
    test('counts only autoPay bills due this month', () {
      final bills = [
        _bill(
          id: 'a',
          amount: 100,
          dueDate: DateTime(2026, 4, 1),
          autoPay: true,
        ),
        _bill(
          id: 'b',
          amount: 200,
          dueDate: DateTime(2026, 4, 30),
          autoPay: false,
        ),
        _bill(
          id: 'c',
          amount: 500,
          dueDate: DateTime(2026, 3, 1),
          autoPay: true,
        ),
        _bill(
          id: 'd',
          amount: 75,
          dueDate: DateTime(2026, 4, 15),
          autoPay: true,
        ),
      ];
      expect(BillStats.autoPayCountThisMonth(bills, now), 2);
    });
  });

  group('BillStats.paidFractionThisMonth', () {
    test('returns paid / total in [0,1]', () {
      final bills = [
        _bill(
          id: 'a',
          amount: 100,
          dueDate: DateTime(2026, 4, 1),
          status: BillStatus.paid,
        ),
        _bill(
          id: 'b',
          amount: 300,
          dueDate: DateTime(2026, 4, 20),
          status: BillStatus.upcoming,
        ),
      ];
      expect(BillStats.paidFractionThisMonth(bills, now), closeTo(0.25, 1e-9));
    });

    test('returns 0 when there are no bills due this month', () {
      expect(BillStats.paidFractionThisMonth(const [], now), 0);
    });
  });
}
