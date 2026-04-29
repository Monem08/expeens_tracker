import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/money.dart';
import '../state/settings_store.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthlyChangePct,
  });

  final double balance;
  final double monthlyChangePct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sym = context.watch<SettingsStore>().currencySymbol;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242A2C), Color(0xFF1A1F20)],
        ),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL BALANCE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(balance, symbol: sym),
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.mint,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Profit',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _ChangeIndicator(pct: monthlyChangePct),
                ],
              ),
              const Spacer(),
              const _CardStack(),
            ],
          ),
        ],
      ),
    );
  }

}

class _ChangeIndicator extends StatelessWidget {
  const _ChangeIndicator({required this.pct});

  final double pct;

  @override
  Widget build(BuildContext context) {
    final isPositive = pct >= 0;
    final color = isPositive ? AppColors.mint : AppColors.negative;
    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${pct.abs().toStringAsFixed(1)}%',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 36,
      child: Stack(
        children: [
          Positioned(
            right: 28,
            top: 0,
            child: _MiniCard(color: const Color(0xFF3A4146)),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: _MiniCard(color: AppColors.mint.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
