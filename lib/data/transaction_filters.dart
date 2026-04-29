import '../models/category.dart';
import '../models/transaction.dart';

/// Pure helpers used by the History screen to filter/sort the transaction
/// list. Kept free of Flutter imports so they can be unit-tested directly.
class TransactionFilters {
  const TransactionFilters._();

  /// Case-insensitive substring match against title, category label, and
  /// the optional note.
  static List<Transaction> search(List<Transaction> txs, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return txs;
    return txs.where((t) {
      if (t.title.toLowerCase().contains(q)) return true;
      if (t.category.label.toLowerCase().contains(q)) return true;
      final note = t.note;
      if (note != null && note.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  /// Only transactions whose date is in the same calendar month as [now].
  static List<Transaction> inMonth(List<Transaction> txs, DateTime now) {
    return txs
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  /// Only transactions whose category matches [category]. Passing `null`
  /// is a no-op (returns the list unchanged) so callers can express "All".
  static List<Transaction> byCategory(
    List<Transaction> txs,
    ExpenseCategory? category,
  ) {
    if (category == null) return txs;
    return txs.where((t) => t.category == category).toList();
  }

  /// Descending by absolute amount — biggest spenders first regardless of
  /// sign.
  static List<Transaction> sortedByAmountDesc(List<Transaction> txs) {
    final copy = List<Transaction>.from(txs);
    copy.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return copy;
  }
}
