import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../state/transaction_store.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'add_expense_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'This Month';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _groupByDate(context.watch<TransactionStore>().transactions);

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
            Text(
              'MintyExpense',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterPill(
                  icon: Icons.calendar_today_outlined,
                  label: 'This Month',
                  selected: _selectedFilter == 'This Month',
                  onTap: () => setState(() => _selectedFilter = 'This Month'),
                ),
                const SizedBox(width: 10),
                _FilterPill(
                  icon: Icons.category_outlined,
                  label: 'All Categories',
                  selected: _selectedFilter == 'All Categories',
                  onTap: () =>
                      setState(() => _selectedFilter = 'All Categories'),
                ),
                const SizedBox(width: 10),
                _FilterPill(
                  icon: Icons.swap_vert,
                  label: 'Amount',
                  selected: _selectedFilter == 'Amount',
                  onTap: () => setState(() => _selectedFilter = 'Amount'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                entry.key,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < entry.value.length; i++)
                    _DismissibleTile(
                      transaction: entry.value[i],
                      showDivider: i < entry.value.length - 1,
                      subtitle: _formatSubtitle(entry.value[i]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'LOAD OLDER TRANSACTIONS',
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> txs) {
    final Map<String, List<Transaction>> out = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    for (final t in txs) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final key = d == today
          ? 'TODAY, ${DateFormat('MMM d').format(d).toUpperCase()}'
          : d == yesterday
          ? 'YESTERDAY, ${DateFormat('MMM d').format(d).toUpperCase()}'
          : DateFormat('MMM d, y').format(d).toUpperCase();
      out.putIfAbsent(key, () => []).add(t);
    }
    return out;
  }

  String _formatSubtitle(Transaction t) {
    return '${t.category.label} · ${DateFormat.jm().format(t.date)}';
  }
}

class _DismissibleTile extends StatelessWidget {
  const _DismissibleTile({
    required this.transaction,
    required this.showDivider,
    required this.subtitle,
  });

  final Transaction transaction;
  final bool showDivider;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('tx-${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: theme.colorScheme.error.withValues(alpha: 0.85),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete transaction?'),
                content: Text(
                  '"${transaction.title}" will be removed. You can undo right after.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) async {
        final store = context.read<TransactionStore>();
        final messenger = ScaffoldMessenger.of(context);
        await store.remove(transaction.id);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Deleted "${transaction.title}"'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () => store.add(transaction),
              ),
            ),
          );
      },
      child: TransactionTile(
        transaction: transaction,
        showDivider: showDivider,
        subtitleOverride: subtitle,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(initial: transaction),
            ),
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.mint : AppColors.surfaceHigh;
    final fg = selected
        ? AppColors.onMint
        : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: selected ? null : Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
