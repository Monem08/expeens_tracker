import '../models/bill.dart';

/// Pure helpers used by the Bills screen to narrow the bill list down to
/// what the currently-active tab / section should show.
class BillFilters {
  const BillFilters._();

  /// Only bills whose [Bill.status] equals [status].
  static List<Bill> byStatus(List<Bill> bills, BillStatus status) =>
      bills.where((b) => b.status == status).toList();

  /// Bills whose due date falls in the window `[now, now + window]`
  /// (inclusive on both ends, ordered by soonest first).
  static List<Bill> dueWithin(
    List<Bill> bills, {
    required DateTime now,
    required Duration window,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final end = today.add(window);
    final out = bills.where((b) {
      final d = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day);
      return !d.isBefore(today) && !d.isAfter(end);
    }).toList();
    out.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return out;
  }
}
