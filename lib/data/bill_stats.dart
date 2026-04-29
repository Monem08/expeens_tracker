import '../models/bill.dart';

/// Pure functions that derive the bills-screen summary numbers from a list
/// of bills. Kept free of Flutter / ChangeNotifier dependencies so they can
/// be unit-tested directly.
class BillStats {
  const BillStats._();

  /// Sum of every bill due in the same calendar month as [now].
  static double totalThisMonth(List<Bill> bills, DateTime now) {
    var sum = 0.0;
    for (final b in bills) {
      if (_isSameMonth(b.dueDate, now)) sum += b.amount;
    }
    return sum;
  }

  /// Sum of bills due this month whose status is [BillStatus.paid].
  static double paidThisMonth(List<Bill> bills, DateTime now) {
    var sum = 0.0;
    for (final b in bills) {
      if (_isSameMonth(b.dueDate, now) && b.status == BillStatus.paid) {
        sum += b.amount;
      }
    }
    return sum;
  }

  /// `total - paid`, clamped to zero so the UI never renders a negative
  /// "remaining" amount.
  static double remainingThisMonth(List<Bill> bills, DateTime now) {
    final v = totalThisMonth(bills, now) - paidThisMonth(bills, now);
    return v < 0 ? 0 : v;
  }

  /// Count of bills due this month with auto-pay enabled.
  static int autoPayCountThisMonth(List<Bill> bills, DateTime now) {
    var count = 0;
    for (final b in bills) {
      if (_isSameMonth(b.dueDate, now) && b.autoPay) count++;
    }
    return count;
  }

  /// Fraction of [totalThisMonth] that has been paid, in `[0, 1]`. Returns
  /// `0` when there are no bills due this month so the progress bar stays
  /// empty rather than showing a NaN.
  static double paidFractionThisMonth(List<Bill> bills, DateTime now) {
    final total = totalThisMonth(bills, now);
    if (total <= 0) return 0;
    final pct = paidThisMonth(bills, now) / total;
    if (pct.isNaN || pct < 0) return 0;
    if (pct > 1) return 1;
    return pct;
  }

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
