import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.indigo.withValues(alpha: 0.25)
                  : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.mint : AppColors.outline,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.mint.withValues(alpha: 0.25),
                        blurRadius: 14,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              category.icon,
              color: selected ? AppColors.mint : theme.colorScheme.onSurface,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
