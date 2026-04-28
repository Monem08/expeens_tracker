import 'category.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final ExpenseCategory category;

  /// Positive amounts are income, negative amounts are expenses.
  final double amount;
  final DateTime date;
  final String? note;

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;
}
