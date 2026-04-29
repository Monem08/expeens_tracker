import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_shell.dart';
import '../data/transaction_filters.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../state/settings_store.dart';
import '../state/transaction_store.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/section_header.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExpenseCategory? _selected;

  static const List<ExpenseCategory> _homeCategories = [
    ExpenseCategory.food,
    ExpenseCategory.transport,
    ExpenseCategory.bills,
    ExpenseCategory.shopping,
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TransactionStore>();
    final settings = context.watch<SettingsStore>();
    final filtered = TransactionFilters.byCategory(
      store.transactions,
      _selected,
    );
    final recent = filtered.take(5).toList();
    final weekly = store.weeklySpending();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceHigh,
              child: Icon(
                Icons.person_outline,
                color: AppColors.mint,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MintyExpense',
                    style: TextStyle(
                      color: AppColors.mint,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Hi, ${settings.displayName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          BalanceCard(
            balance: store.totalBalance,
            monthlyChangePct: store.monthlyChangePct(),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Categories',
            trailing: TextButton(
              onPressed: _pickAnyCategory,
              child: const Text('See All'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final c in _homeCategories)
                CategoryChip(
                  category: c,
                  selected: c == _selected,
                  onTap: () => setState(() {
                    _selected = _selected == c ? null : c;
                  }),
                ),
            ],
          ),
          if (_selected != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _selected = null),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear filter'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const SectionHeader(title: "This Week's Spending"),
          const SizedBox(height: 8),
          SpendingChart(values: weekly),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recent Transactions',
            trailing: TextButton(
              onPressed: () {
                AppShellController.of(context)?.switchTo(3);
              },
              child: const Text('See All'),
            ),
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Center(
                child: Text(
                  _selected == null
                      ? 'No transactions yet — tap + to add one'
                      : 'No ${_selected!.label.toLowerCase()} transactions yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < recent.length; i++)
                    TransactionTile(
                      transaction: recent[i],
                      showDivider: i < recent.length - 1,
                      onTap: () => _edit(context, recent[i]),
                      onLongPress: () => _showActions(context, recent[i]),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAnyCategory() async {
    final picked = await showCategoryPicker(context, selected: _selected);
    if (picked != null) setState(() => _selected = picked);
  }

  Future<void> _edit(BuildContext context, Transaction tx) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(initial: tx),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, Transaction tx) async {
    final store = context.read<TransactionStore>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.of(ctx).pop('edit'),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
                onTap: () => Navigator.of(ctx).pop('delete'),
              ),
            ],
          ),
        );
      },
    );
    if (action == 'edit') {
      await navigator.push(
        MaterialPageRoute(builder: (_) => AddExpenseScreen(initial: tx)),
      );
    } else if (action == 'delete') {
      await store.remove(tx.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Deleted "${tx.title}"'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () => store.add(tx),
            ),
          ),
        );
    }
  }
}
