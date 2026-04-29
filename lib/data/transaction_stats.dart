import '../models/transaction.dart';

/// Pure functions that derive home-screen statistics from a list of
/// transactions. Kept free of Flutter / ChangeNotifier dependencies so they
/// can be unit-tested directly.
class TransactionStats {
  const TransactionStats._();

  /// Net of all transactions (income minus expenses).
  static double totalBalance(List<Transaction> txs) {
    var sum = 0.0;
    for (final tx in txs) {
      sum += tx.amount;
    }
    return sum;
  }

  /// Percentage change in this month's net vs last month's net.
  ///
  /// When last month has no transactions, falls back to the current month's
  /// profit margin (`net / income * 100`). Returns `0` when neither
  /// reference value is meaningful.
  static double monthlyChangePct(List<Transaction> txs, DateTime now) {
    final thisMonthStart = DateTime(now.year, now.month);
    final lastMonthStart = DateTime(now.year, now.month - 1);

    var thisNet = 0.0;
    var thisIncome = 0.0;
    var lastNet = 0.0;
    for (final tx in txs) {
      if (!tx.date.isBefore(thisMonthStart)) {
        thisNet += tx.amount;
        if (tx.isIncome) thisIncome += tx.amount;
      } else if (!tx.date.isBefore(lastMonthStart)) {
        lastNet += tx.amount;
      }
    }

    if (lastNet != 0) {
      return ((thisNet - lastNet) / lastNet.abs()) * 100;
    }
    if (thisIncome > 0) {
      return (thisNet / thisIncome) * 100;
    }
    return 0;
  }

  /// Total expense (as a positive value) for each weekday Mon..Sun of the
  /// week that contains [now].
  static List<double> weeklySpending(List<Transaction> txs, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    // DateTime.weekday: Mon=1..Sun=7 → Monday is index 0.
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final buckets = List<double>.filled(7, 0);
    for (final tx in txs) {
      if (!tx.isExpense) continue;
      final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final delta = d.difference(monday).inDays;
      if (delta < 0 || delta > 6) continue;
      buckets[delta] += -tx.amount;
    }
    return buckets;
  }

  /// Index of the largest bucket in [buckets], or `null` when every bucket
  /// is zero (so the chart doesn't render a phantom highlight).
  static int? peakIndex(List<double> buckets) {
    var maxValue = 0.0;
    int? maxIndex;
    for (var i = 0; i < buckets.length; i++) {
      if (buckets[i] > maxValue) {
        maxValue = buckets[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }
}
