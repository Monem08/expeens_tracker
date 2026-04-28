import 'bill_repository.dart';
import 'mock_data.dart';
import 'transaction_repository.dart';

/// Seeds the database with the initial mock content on first launch.
/// Safe to call repeatedly — it only writes if both tables are empty.
Future<void> seedIfNeeded({
  required TransactionRepository transactions,
  required BillRepository bills,
}) async {
  if (await transactions.count() == 0) {
    for (final tx in MockData.seedTransactions()) {
      await transactions.insert(tx);
    }
  }
  if (await bills.count() == 0) {
    for (final bill in MockData.seedBills()) {
      await bills.insert(bill);
    }
  }
}
