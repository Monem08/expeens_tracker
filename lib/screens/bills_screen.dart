import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/money.dart';
import '../models/bill.dart';
import '../state/bill_store.dart';
import '../state/settings_store.dart';
import '../theme/app_theme.dart';
import '../widgets/bill_tile.dart';
import '../widgets/section_header.dart';
import 'add_bill_screen.dart';
import 'bill_details_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  BillStatus _tab = BillStatus.upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<BillStore>();
    final visibleBills = _tab == BillStatus.upcoming
        ? store.bills
              .where(
                (b) =>
                    b.status == BillStatus.upcoming ||
                    b.status == BillStatus.overdue ||
                    b.status == BillStatus.scheduled ||
                    b.status == BillStatus.priority,
              )
              .toList()
        : store.filteredByStatus(_tab);
    final next7 = store.dueNext7Days();
    final autoPayCount = store.autoPayCountThisMonth();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(
          'Bill Reminders',
          style: TextStyle(
            color: AppColors.mint,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add bill',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.mint),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddBillScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const _TotalBillsCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              _BillTab(
                label: 'Upcoming',
                selected: _tab == BillStatus.upcoming,
                onTap: () => setState(() => _tab = BillStatus.upcoming),
              ),
              const SizedBox(width: 8),
              _BillTab(
                label: 'Paid',
                selected: _tab == BillStatus.paid,
                onTap: () => setState(() => _tab = BillStatus.paid),
              ),
              const SizedBox(width: 8),
              _BillTab(
                label: 'Overdue',
                selected: _tab == BillStatus.overdue,
                onTap: () => setState(() => _tab = BillStatus.overdue),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_tab == BillStatus.upcoming) ...[
            SectionHeader(
              title: 'Next 7 Days',
              trailing: Text(
                '${next7.length} PENDING',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (next7.isEmpty)
              _EmptyBox(
                text: 'No bills due in the next 7 days',
              )
            else
              for (final bill in next7) ...[
                _BillRow(bill: bill),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 20),
            SectionHeader(
              title: 'All ${_tabTitle(_tab)}',
              trailing: Text(
                '${visibleBills.length} TOTAL',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (visibleBills.isEmpty)
            _EmptyBox(text: 'No ${_tabTitle(_tab).toLowerCase()} bills')
          else
            for (final bill in visibleBills) ...[
              _BillRow(bill: bill),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-Pay',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        autoPayCount == 1
                            ? '1 bill is set to auto-transfer this month'
                            : '$autoPayCount bills are set to auto-transfer this month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.mint.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(Icons.autorenew, color: AppColors.mint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tabTitle(BillStatus s) {
    switch (s) {
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.overdue:
        return 'Overdue';
      case BillStatus.upcoming:
      case BillStatus.scheduled:
      case BillStatus.priority:
        return 'Upcoming';
    }
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('bill-${bill.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete bill?'),
                content: Text(
                  '"${bill.name}" will be removed permanently.',
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
        final store = context.read<BillStore>();
        final messenger = ScaffoldMessenger.of(context);
        await store.remove(bill.id);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Deleted "${bill.name}"'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () => store.upsert(bill),
              ),
            ),
          );
      },
      child: BillTile(
        bill: bill,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BillDetailsScreen(bill: bill),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TotalBillsCard extends StatelessWidget {
  const _TotalBillsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<BillStore>();
    final settings = context.watch<SettingsStore>();
    final sym = settings.currencySymbol;
    final total = store.totalThisMonth();
    final paid = store.paidThisMonth();
    final remaining = store.remainingThisMonth();
    final pct = store.paidFractionThisMonth();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL MONTHLY BILLS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(total, symbol: sym),
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mint,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'due this month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.mint),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatMoney(paid, symbol: sym)} PAID',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${formatMoney(remaining, symbol: sym)} REMAINING',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillTab extends StatelessWidget {
  const _BillTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: selected ? null : Border.all(color: AppColors.outline),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
