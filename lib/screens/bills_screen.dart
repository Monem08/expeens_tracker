import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/bill.dart';
import '../state/bill_store.dart';
import '../theme/app_theme.dart';
import '../widgets/bill_tile.dart';
import '../widgets/section_header.dart';
import 'bill_details_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  BillStatus? _tab = BillStatus.upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<BillStore>();
    final bills = store.upcoming;
    final autoPayCount = store.autoPayCountThisMonth();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: AppColors.mint,
          onPressed: () {},
        ),
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
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.mint,
            ),
            onPressed: () {},
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
          SectionHeader(
            title: 'Next 7 Days',
            trailing: Text(
              '${bills.length} PENDING',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final bill in bills) ...[
            BillTile(
              bill: bill,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BillDetailsScreen(bill: bill),
                  ),
                );
              },
            ),
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
                        'Auto-Pay Active',
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
                  child: const Icon(Icons.check, color: AppColors.mint),
                ),
              ],
            ),
          ),
        ],
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
                '\$${_formatMoney(total)}',
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
                '\$${_formatMoney(paid)} PAID',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${_formatMoney(remaining)} REMAINING',
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

  String _formatMoney(double value) {
    final s = value.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${buf.toString()}.${parts[1]}';
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
