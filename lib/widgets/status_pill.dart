import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final BillStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      BillStatus.priority => (AppColors.negative, 'PRIORITY'),
      BillStatus.overdue => (AppColors.negative, 'OVERDUE'),
      BillStatus.upcoming => (AppColors.mint, 'UPCOMING'),
      BillStatus.scheduled => (AppColors.mint, 'SCHEDULED'),
      BillStatus.paid => (AppColors.mint, 'PAID'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
