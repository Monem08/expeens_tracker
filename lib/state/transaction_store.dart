import 'package:flutter/foundation.dart';

import '../data/transaction_repository.dart';
import '../data/transaction_stats.dart';
import '../models/transaction.dart';

class TransactionStore extends ChangeNotifier {
  TransactionStore(this._repo);

  final TransactionRepository _repo;

  List<Transaction> _transactions = const [];
  bool _loading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _loading;

  List<Transaction> get recent => _transactions.take(3).toList();

  double get totalBalance => TransactionStats.totalBalance(_transactions);

  double monthlyChangePct([DateTime? now]) =>
      TransactionStats.monthlyChangePct(_transactions, now ?? DateTime.now());

  List<double> weeklySpending([DateTime? now]) =>
      TransactionStats.weeklySpending(_transactions, now ?? DateTime.now());

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _transactions = await _repo.all();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Transaction tx) async {
    await _repo.insert(tx);
    await load();
  }

  /// Upserts [tx]. Works for both insert and update because the
  /// repository uses `ConflictAlgorithm.replace`.
  Future<void> update(Transaction tx) async {
    await _repo.insert(tx);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }
}
