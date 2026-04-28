import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'data/app_database.dart';
import 'data/bill_repository.dart';
import 'data/seed.dart';
import 'data/transaction_repository.dart';
import 'state/bill_store.dart';
import 'state/transaction_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.instance();
  final transactionRepo = TransactionRepository(db);
  final billRepo = BillRepository(db);
  await seedIfNeeded(transactions: transactionRepo, bills: billRepo);

  final transactionStore = TransactionStore(transactionRepo);
  final billStore = BillStore(billRepo);
  await Future.wait([transactionStore.load(), billStore.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: transactionStore),
        ChangeNotifierProvider.value(value: billStore),
      ],
      child: const ExpeensTrackerApp(),
    ),
  );
}

class ExpeensTrackerApp extends StatelessWidget {
  const ExpeensTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MintyExpense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
