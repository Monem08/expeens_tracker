import 'package:flutter/foundation.dart';

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
}
