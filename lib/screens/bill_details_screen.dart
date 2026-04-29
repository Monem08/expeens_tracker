import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/money.dart';
import '../models/bill.dart';
import '../state/bill_store.dart';
import '../state/settings_store.dart';
import '../theme/app_theme.dart';
import 'add_bill_screen.dart';

class BillDetailsScreen extends StatefulWidget {
  const BillDetailsScreen({super.key, required this.bill});

  final Bill bill;

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<BillStore>();
    final bill = store.bills.firstWhere(
      (b) => b.id == widget.bill.id,
      orElse: () => widget.bill,
    );
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(
      bill.dueDate.year,
      bill.dueDate.month,
      bill.dueDate.day,
    );
    final daysUntilDue = dueMidnight.difference(todayMidnight).inDays;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mint),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bill Details',
          style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.mint),
            onPressed: () => _showMoreActions(context, bill),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.mint.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mint.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(bill.icon, color: AppColors.mint, size: 32),
                ),
                const SizedBox(height: 14),
                Text(
                  bill.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _DueBadge(daysUntilDue: daysUntilDue),
                const SizedBox(height: 8),
                Text(
                  formatMoney(
                    bill.amount,
                    symbol: context.watch<SettingsStore>().currencySymbol,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mint,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.payments_outlined,
                  label: bill.status == BillStatus.paid ? 'Paid' : 'Pay Now',
                  selected: bill.status != BillStatus.paid,
                  onTap: bill.status == BillStatus.paid
                      ? () {}
                      : () => _markPaid(context, bill),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Mark Paid',
                  onTap: bill.status == BillStatus.paid
                      ? () {}
                      : () => _markPaid(context, bill),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit Bill',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddBillScreen(initial: bill),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AutoPayRow(
            autoPay: bill.autoPay,
            nextDate: bill.dueDate,
            onChanged: (v) => store.setAutoPay(bill.id, v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'ACCOUNT NO.',
                  value: '**** ${bill.accountLast4 ?? '----'}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  label: 'DUE DATE',
                  value: DateFormat('MMM d').format(bill.dueDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoTile(
            label: 'BILLING PERIOD',
            value:
                bill.billingPeriodStart != null && bill.billingPeriodEnd != null
                ? '${DateFormat('MMM d').format(bill.billingPeriodStart!)} – '
                      '${DateFormat('MMM d, y').format(bill.billingPeriodEnd!)}'
                : '—',
            trailing: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.mint,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Payment History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppColors.mint,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < bill.paymentHistory.length; i++) ...[
            _PaymentRow(payment: bill.paymentHistory[i], highlight: i == 0),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          _BillerCard(biller: bill.biller),
        ],
      ),
    );
  }

  Future<void> _markPaid(BuildContext context, Bill bill) async {
    final store = context.read<BillStore>();
    final messenger = ScaffoldMessenger.of(context);
    await store.markPaid(bill.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Marked "${bill.name}" as paid')),
      );
  }

  Future<void> _showMoreActions(BuildContext context, Bill bill) async {
    final store = context.read<BillStore>();
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
                title: const Text('Edit bill'),
                onTap: () => Navigator.of(ctx).pop('edit'),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error,
                ),
                title: Text(
                  'Delete bill',
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
      navigator.push(
        MaterialPageRoute(
          builder: (_) => AddBillScreen(initial: bill),
        ),
      );
    } else if (action == 'delete') {
      await store.remove(bill.id);
      if (navigator.canPop()) navigator.pop();
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
    }
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.daysUntilDue});

  final int daysUntilDue;

  @override
  Widget build(BuildContext context) {
    final isOverdue = daysUntilDue < 0;
    final isSoon = daysUntilDue <= 3 && daysUntilDue >= 0;
    final color = (isSoon || isOverdue) ? AppColors.negative : AppColors.mint;
    final text = daysUntilDue < 0
        ? 'Overdue'
        : daysUntilDue == 0
        ? 'Due today'
        : 'Due in $daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            (isSoon || isOverdue) ? Icons.priority_high : Icons.info_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.mint : AppColors.surfaceHigh;
    final fg = selected
        ? AppColors.onMint
        : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: selected ? null : Border.all(color: AppColors.outline),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.mint.withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoPayRow extends StatelessWidget {
  const _AutoPayRow({
    required this.autoPay,
    required this.nextDate,
    required this.onChanged,
  });

  final bool autoPay;
  final DateTime nextDate;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.autorenew, color: AppColors.mint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Pay Active',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Next: ${DateFormat('MMM d, y').format(nextDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: autoPay,
            onChanged: onChanged,
            activeThumbColor: AppColors.onMint,
            activeTrackColor: AppColors.mint,
            inactiveTrackColor: AppColors.surfaceHigh,
            inactiveThumbColor: Colors.white70,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.highlight});

  final BillPayment payment;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sym = context.watch<SettingsStore>().currencySymbol;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.mint : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.mint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.succeeded ? 'Paid Successfully' : 'Payment Failed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${DateFormat('MMM d, y').format(payment.date)} · '
                  '${DateFormat.jm().format(payment.date)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatMoney(payment.amount, symbol: sym),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillerCard extends StatelessWidget {
  const _BillerCard({required this.biller});

  final String biller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface,
        border: Border.all(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1F2628), Color(0xFF0F1314)],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.factory_outlined,
                size: 56,
                color: AppColors.outline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: AppColors.indigo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        biller,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Official Utility Biller',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mint,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiniIconLabel(icon: Icons.public, label: 'Website'),
                const SizedBox(width: 12),
                _MiniIconLabel(icon: Icons.support_agent, label: 'Support'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIconLabel extends StatelessWidget {
  const _MiniIconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
