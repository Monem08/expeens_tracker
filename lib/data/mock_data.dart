import '../models/bill.dart';
import '../models/category.dart';
import '../models/transaction.dart';

/// Seed data used to populate a freshly-created SQLite database. All
/// home-screen and bills-screen summary numbers are now derived from the
/// real persisted stores.
class MockData {
  const MockData._();

  static List<Transaction> seedTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    return [
      Transaction(
        id: 't1',
        title: 'Apple Store',
        category: ExpenseCategory.electronics,
        amount: -1299.00,
        date: today.copyWith(hour: 14, minute: 34),
      ),
      Transaction(
        id: 't2',
        title: 'Starbucks',
        category: ExpenseCategory.coffee,
        amount: -6.50,
        date: today.copyWith(hour: 8, minute: 15),
      ),
      Transaction(
        id: 't3',
        title: 'Salary Deposit',
        category: ExpenseCategory.income,
        amount: 4500.00,
        date: yesterday.copyWith(hour: 9),
        note: 'Yesterday',
      ),
      Transaction(
        id: 't4',
        title: 'Uber Ride',
        category: ExpenseCategory.transport,
        amount: -24.30,
        date: yesterday.copyWith(hour: 18, minute: 45),
      ),
      Transaction(
        id: 't5',
        title: 'Chevron Gas',
        category: ExpenseCategory.transport,
        amount: -54.20,
        date: today.subtract(const Duration(days: 19)),
      ),
    ];
  }

  static List<Bill> seedBills() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      Bill(
        id: 'b1',
        name: 'Electricity Bill',
        biller: 'City Grid Electric',
        amount: 142.50,
        dueDate: today.add(const Duration(days: 2)),
        status: BillStatus.priority,
        iconKind: BillIconKind.bolt,
        accountLast4: '8842',
        autoPay: true,
        billingPeriodStart: today.subtract(const Duration(days: 34)),
        billingPeriodEnd: today.subtract(const Duration(days: 4)),
        paymentHistory: [
          BillPayment(
            amount: 138.20,
            date: today.subtract(const Duration(days: 28)),
            succeeded: true,
          ),
          BillPayment(
            amount: 145.10,
            date: today.subtract(const Duration(days: 59)),
            succeeded: true,
          ),
        ],
      ),
      Bill(
        id: 'b2',
        name: 'Internet & TV',
        biller: 'SkyFiber',
        amount: 89.00,
        dueDate: today,
        status: BillStatus.upcoming,
        iconKind: BillIconKind.wifi,
      ),
      Bill(
        id: 'b3',
        name: 'Monthly Rent',
        biller: 'Palmwood Apartments',
        amount: 1200.00,
        dueDate: today.add(const Duration(days: 4)),
        status: BillStatus.scheduled,
        iconKind: BillIconKind.apartment,
      ),
      Bill(
        id: 'b4',
        name: 'Car Insurance',
        biller: 'SafeDrive Co.',
        amount: 215.00,
        dueDate: today.subtract(const Duration(days: 3)),
        status: BillStatus.overdue,
        iconKind: BillIconKind.shield,
      ),
    ];
  }
}
