import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key, required this.values, this.highlightIndex});

  final List<double> values;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    final hasData = maxValue > 0;
    final highlight = hasData
        ? (highlightIndex ?? values.indexOf(maxValue))
        : -1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      height: 210,
      child: BarChart(
        BarChartData(
          maxY: hasData ? maxValue * 1.25 : 1,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  final isHighlight = i == highlight;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isHighlight
                            ? AppColors.mint
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isHighlight
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: 24,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    gradient: _rodGradient(i == highlight),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceHigh,
              getTooltipItem: (group, groupIdx, rod, rodIdx) {
                return BarTooltipItem(
                  '\$${rod.toY.toStringAsFixed(2)}',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _rodGradient(bool highlight) {
    if (highlight) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.mint, Color(0xFF00C89A)],
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.mint.withValues(alpha: 0.4),
        AppColors.mint.withValues(alpha: 0.15),
      ],
    );
  }
}
