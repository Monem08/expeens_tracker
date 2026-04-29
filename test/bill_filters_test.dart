import 'package:expeens_tracker/data/bill_filters.dart';
import 'package:expeens_tracker/models/bill.dart';
import 'package:flutter_test/flutter_test.dart';

Bill _bill({
  required String id,
  required BillStatus status,
  required DateTime dueDate,
}) {
  return Bill(
    id: id,
    name: 'Bill $id',
    biller: 'Biller',
    amount: 10,
    dueDate: dueDate,
    status: status,
    iconKind: BillIconKind.generic,
  );
}

void main() {
  group('BillFilters.byStatus', () {
    test('filters to matching status only', () {
      final bills = [
        _bill(id: '1', status: BillStatus.paid, dueDate: DateTime(2026, 3, 1)),
        _bill(
          id: '2',
          status: BillStatus.upcoming,
          dueDate: DateTime(2026, 3, 2),
        ),
        _bill(
          id: '3',
          status: BillStatus.overdue,
          dueDate: DateTime(2026, 2, 28),
        ),
      ];
      expect(
        BillFilters.byStatus(bills, BillStatus.paid).map((b) => b.id),
        ['1'],
      );
      expect(
        BillFilters.byStatus(bills, BillStatus.upcoming).map((b) => b.id),
        ['2'],
      );
    });
  });

  group('BillFilters.dueWithin', () {
    test('7-day window inclusive of both endpoints, sorted by date', () {
      final now = DateTime(2026, 3, 15);
      final bills = [
        _bill(
          id: 'before',
          status: BillStatus.upcoming,
          dueDate: DateTime(2026, 3, 14),
        ),
        _bill(
          id: 'today',
          status: BillStatus.upcoming,
          dueDate: DateTime(2026, 3, 15),
        ),
        _bill(
          id: 'plus3',
          status: BillStatus.upcoming,
          dueDate: DateTime(2026, 3, 18),
        ),
        _bill(
          id: 'plus7',
          status: BillStatus.upcoming,
          dueDate: DateTime(2026, 3, 22),
        ),
        _bill(
          id: 'plus8',
          status: BillStatus.upcoming,
          dueDate: DateTime(2026, 3, 23),
        ),
      ];
      final out = BillFilters.dueWithin(
        bills,
        now: now,
        window: const Duration(days: 7),
      );
      expect(out.map((b) => b.id), ['today', 'plus3', 'plus7']);
    });
  });
}
