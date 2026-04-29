import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet listing all [ExpenseCategory] values in a grid.
///
/// Returns the chosen category, or `null` when dismissed. Pass the currently
/// active category in [selected] to highlight it.
Future<ExpenseCategory?> showCategoryPicker(
  BuildContext context, {
  ExpenseCategory? selected,
}) {
  return showModalBottomSheet<ExpenseCategory>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _CategoryPickerBody(selected: selected),
  );
}

class _CategoryPickerBody extends StatelessWidget {
  const _CategoryPickerBody({required this.selected});

  final ExpenseCategory? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ExpenseCategory.values;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Pick a category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                for (final c in categories)
                  _PickerTile(
                    category: c,
                    selected: c == selected,
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? AppColors.mint.withValues(alpha: 0.18)
        : AppColors.surfaceHigh;
    final border = selected ? AppColors.mint : AppColors.outline;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: AppColors.mint, size: 26),
              const SizedBox(height: 6),
              Text(
                category.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
