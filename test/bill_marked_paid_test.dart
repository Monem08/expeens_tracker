import 'package:expeens_tracker/models/bill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bill.markedPaid', () {
    test('flips status to paid and appends a successful payment at top', () {
      final bill = Bill(
        id: 'b1',
        name: 'Electric',
        biller: 'PowerCo',
        amount: 82.50,
        dueDate: DateTime(2026, 3, 15),
        status: BillStatus.upcoming,
        iconKind: BillIconKind.generic,
        autoPay: false,
        paymentHistory: const [],
      );
      final when = DateTime(2026, 3, 10, 14, 30);
      final paid = bill.markedPaid(when: when);

      expect(paid.status, BillStatus.paid);
      expect(paid.paymentHistory, hasLength(1));
      expect(paid.paymentHistory.first.amount, 82.50);
      expect(paid.paymentHistory.first.succeeded, isTrue);
      expect(paid.paymentHistory.first.date, when);
      // original is not mutated
      expect(bill.status, BillStatus.upcoming);
      expect(bill.paymentHistory, isEmpty);
    });

    test('prepends the new payment to existing history', () {
      final earlier = BillPayment(
        amount: 50,
        date: DateTime(2026, 1, 1),
        succeeded: true,
      );
      final bill = Bill(
        id: 'b1',
        name: 'Water',
        biller: 'WaterCo',
        amount: 60,
        dueDate: DateTime(2026, 3, 15),
        status: BillStatus.upcoming,
        iconKind: BillIconKind.generic,
        paymentHistory: [earlier],
      );
      final paid = bill.markedPaid(when: DateTime(2026, 3, 10));
      expect(paid.paymentHistory.map((p) => p.amount), [60, 50]);
    });
  });
}
