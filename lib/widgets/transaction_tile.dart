import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/money.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../state/settings_store.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.showDivider = false,
    this.subtitleOverride,
    this.onTap,
    this.onLongPress,
  });

  final Transaction transaction;
  final bool showDivider;

  /// Optional custom subtitle (e.g. "Electronics · 2:34 PM").
  final String? subtitleOverride;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = transaction;
    final isIncome = t.isIncome;

    final sym = context.watch<SettingsStore>().currencySymbol;
    final amountText =
        '${isIncome ? '+' : '-'}${formatMoney(t.amount.abs(), symbol: sym)}';

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _Leading(category: t.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleOverride ?? _defaultSubtitle(t),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amountText,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isIncome ? AppColors.mint : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        if (onTap == null && onLongPress == null)
          row
        else
          InkWell(onTap: onTap, onLongPress: onLongPress, child: row),
        if (showDivider) const Divider(indent: 74, endIndent: 14, height: 1),
      ],
    );
  }

  String _defaultSubtitle(Transaction t) {
    if (t.note != null && t.note!.isNotEmpty) return t.note!;
    return '${t.category.label} · ${DateFormat.jm().format(t.date)}';
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    final isIncome = category == ExpenseCategory.income;
    final tint = isIncome
        ? AppColors.mint.withValues(alpha: 0.18)
        : AppColors.indigo.withValues(alpha: 0.22);
    final iconColor = isIncome
        ? AppColors.mint
        : Theme.of(context).colorScheme.onSurface;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(category.icon, color: iconColor, size: 22),
    );
  }
}
