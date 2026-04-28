import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/category.dart';
import '../state/transaction_store.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/section_header.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExpenseCategory _selected = ExpenseCategory.food;

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionStore>().recent;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceHigh,
              child: Icon(
                Icons.person_outline,
                color: AppColors.mint,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'MintyExpense',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          BalanceCard(
            balance: MockData.totalBalance,
            monthlyChangePct: MockData.monthlyProfitPct,
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Categories',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final c in MockData.homeCategories)
                CategoryChip(
                  category: c,
                  selected: c == _selected,
                  onTap: () => setState(() => _selected = c),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Monthly Spending'),
          const SizedBox(height: 8),
          const SpendingChart(
            values: MockData.weeklySpending,
            highlightIndex: 4,
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recent Transactions',
            trailing: IconButton(
              icon: const Icon(Icons.tune_outlined, size: 20),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++)
                  TransactionTile(
                    transaction: transactions[i],
                    showDivider: i < transactions.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
