import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/money.dart';
import '../models/bill.dart';
import '../state/settings_store.dart';
import '../theme/app_theme.dart';
import 'status_pill.dart';

class BillTile extends StatelessWidget {
  const BillTile({super.key, required this.bill, this.onTap});

  final Bill bill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = bill.status == BillStatus.overdue;
    final sym = context.watch<SettingsStore>().currencySymbol;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? AppColors.negative.withValues(alpha: 0.5)
                  : AppColors.outline,
            ),
          ),
          child: Row(
            children: [
              _Leading(icon: bill.icon, accent: isOverdue),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(bill),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? AppColors.negative
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(bill.amount, symbol: sym),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StatusPill(status: bill.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Bill bill) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      bill.dueDate.year,
      bill.dueDate.month,
      bill.dueDate.day,
    );
    final days = due.difference(today).inDays;
    if (bill.status == BillStatus.overdue) {
      final overdue = (-days).clamp(1, 999);
      return 'Overdue by $overdue ${overdue == 1 ? 'day' : 'days'}';
    }
    if (bill.status == BillStatus.priority) {
      if (days == 0) return 'Due today';
      if (days > 0) return 'Due in $days ${days == 1 ? 'day' : 'days'}';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[bill.dueDate.month - 1]} ${bill.dueDate.day}, ${bill.dueDate.year}';
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.icon, required this.accent});

  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.negative : AppColors.mint;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
