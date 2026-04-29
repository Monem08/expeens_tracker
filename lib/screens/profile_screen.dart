import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/money.dart';
import '../state/bill_store.dart';
import '../state/settings_store.dart';
import '../state/transaction_store.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _currencyOptions = [r'$', '€', '£', '¥', '₹', '৳', '₽', '₩'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsStore>();
    final txStore = context.watch<TransactionStore>();
    final billStore = context.watch<BillStore>();
    final sym = settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(
          'Profile',
          style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _HeaderCard(
            name: settings.displayName,
            balance: formatMoney(txStore.totalBalance, symbol: sym),
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'At a glance'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'TRANSACTIONS',
                  value: txStore.transactions.length.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'BILLS',
                  value: billStore.bills.length.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'AUTO-PAY',
                  value: billStore.autoPayCountThisMonth().toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Preferences'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Display name'),
                subtitle: Text(settings.displayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editDisplayName(context, settings),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: const Text('Currency symbol'),
                subtitle: Text(settings.currencySymbol),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickCurrency(context, settings),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'Data'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: const Text('Export data to clipboard'),
                subtitle: const Text('JSON snapshot of transactions & bills'),
                onTap: () => _exportData(context, txStore, billStore),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Reset all data',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Removes every transaction and bill'),
                onTap: () => _resetData(context, txStore, billStore),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: 'About'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('MintyExpense'),
                subtitle: const Text('Version 0.1.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editDisplayName(BuildContext context, SettingsStore s) async {
    final controller = TextEditingController(text: s.displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) await s.setDisplayName(result);
  }

  Future<void> _pickCurrency(BuildContext context, SettingsStore s) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick a currency symbol',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in _currencyOptions)
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(c),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: c == s.currencySymbol
                                ? AppColors.mint.withValues(alpha: 0.18)
                                : AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: c == s.currencySymbol
                                  ? AppColors.mint
                                  : AppColors.outline,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            c,
                            style: const TextStyle(
                              color: AppColors.mint,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) await s.setCurrencySymbol(result);
  }

  Future<void> _exportData(
    BuildContext context,
    TransactionStore txStore,
    BillStore billStore,
  ) async {
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': txStore.transactions.map((t) => t.toMap()).toList(),
      'bills': billStore.bills.map((b) => b.toMap()).toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(payload);
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${txStore.transactions.length} transactions + '
            '${billStore.bills.length} bills to clipboard',
          ),
        ),
      );
  }

  Future<void> _resetData(
    BuildContext context,
    TransactionStore txStore,
    BillStore billStore,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This permanently removes every transaction and bill. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await Future.wait([txStore.clear(), billStore.clear()]);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('All data cleared')));
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.name, required this.balance});

  final String name;
  final String balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.mint),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.mint,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Net balance: $balance',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.mint,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
