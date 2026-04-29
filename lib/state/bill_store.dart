import 'package:flutter/foundation.dart';

import '../data/bill_filters.dart';
import '../data/bill_repository.dart';
import '../data/bill_stats.dart';
import '../models/bill.dart';

class BillStore extends ChangeNotifier {
  BillStore(this._repo);

  final BillRepository _repo;

  List<Bill> _bills = const [];
  bool _loading = false;

  List<Bill> get bills => _bills;
  bool get isLoading => _loading;

  List<Bill> get upcoming =>
      _bills.where((b) => b.status != BillStatus.paid).toList();

  List<Bill> filteredByStatus(BillStatus status) =>
      BillFilters.byStatus(_bills, status);

  List<Bill> dueNext7Days([DateTime? now]) => BillFilters.dueWithin(
    _bills.where((b) => b.status != BillStatus.paid).toList(),
    now: now ?? DateTime.now(),
    window: const Duration(days: 7),
  );

  double totalThisMonth([DateTime? now]) =>
      BillStats.totalThisMonth(_bills, now ?? DateTime.now());

  double paidThisMonth([DateTime? now]) =>
      BillStats.paidThisMonth(_bills, now ?? DateTime.now());

  double remainingThisMonth([DateTime? now]) =>
      BillStats.remainingThisMonth(_bills, now ?? DateTime.now());

  int autoPayCountThisMonth([DateTime? now]) =>
      BillStats.autoPayCountThisMonth(_bills, now ?? DateTime.now());

  double paidFractionThisMonth([DateTime? now]) =>
      BillStats.paidFractionThisMonth(_bills, now ?? DateTime.now());

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _bills = await _repo.all();
    _loading = false;
    notifyListeners();
  }

  Future<void> setAutoPay(String id, bool autoPay) async {
    await _repo.setAutoPay(id, autoPay);
    await load();
  }

  Future<void> upsert(Bill bill) async {
    await _repo.insert(bill);
    await load();
  }

  Future<void> markPaid(String id, {DateTime? when}) async {
    final bill = _bills.firstWhere((b) => b.id == id);
    await _repo.insert(bill.markedPaid(when: when));
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> clear() async {
    await _repo.deleteAll();
    await load();
  }
}
