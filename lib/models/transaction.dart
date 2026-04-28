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

  Transaction copyWith({
    String? id,
    String? title,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  static Transaction fromMap(Map<String, Object?> map) {
    return Transaction(
      id: map['id']! as String,
      title: map['title']! as String,
      category: ExpenseCategory.values.byName(map['category']! as String),
      amount: (map['amount']! as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']! as int),
      note: map['note'] as String?,
    );
  }
}
