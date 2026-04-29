import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/bill.dart';
import '../state/bill_store.dart';
import '../theme/app_theme.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key, this.initial});

  /// When provided the screen edits an existing bill — fields prefill and
  /// saving upserts the row (same id).
  final Bill? initial;

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _billerCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _last4Ctrl;
  late DateTime _dueDate;
  late BillIconKind _iconKind;
  late bool _autoPay;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _billerCtrl = TextEditingController(text: b?.biller ?? '');
    _amountCtrl = TextEditingController(
      text: b == null ? '' : b.amount.toStringAsFixed(2),
    );
    _last4Ctrl = TextEditingController(text: b?.accountLast4 ?? '');
    _dueDate = b?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _iconKind = b?.iconKind ?? BillIconKind.generic;
    _autoPay = b?.autoPay ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _billerCtrl.dispose();
    _amountCtrl.dispose();
    _last4Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Bill' : 'Add Bill',
          style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.mint.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    _iconKind.icon,
                    color: AppColors.mint,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'AMOUNT',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _amountCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    style: GoogleFonts.inter(
                      color: AppColors.mint,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(label: 'Bill name'),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Electricity, Rent…'),
          ),
          const SizedBox(height: 12),
          _FieldLabel(label: 'Biller'),
          TextField(
            controller: _billerCtrl,
            decoration: const InputDecoration(hintText: 'Company or service'),
          ),
          const SizedBox(height: 12),
          _FieldLabel(label: 'Due date'),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.mint,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('MMM d, y').format(_dueDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(label: 'Icon'),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BillIconKind.values.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final kind = BillIconKind.values[i];
                final selected = kind == _iconKind;
                return GestureDetector(
                  onTap: () => setState(() => _iconKind = kind),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint.withValues(alpha: 0.18)
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.mint : AppColors.outline,
                      ),
                    ),
                    child: Icon(kind.icon, color: AppColors.mint),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(label: 'Account last 4 (optional)'),
          TextField(
            controller: _last4Ctrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: '1234'),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            value: _autoPay,
            onChanged: (v) => setState(() => _autoPay = v),
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-pay'),
            subtitle: const Text('Charge automatically when due'),
            activeThumbColor: AppColors.onMint,
            activeTrackColor: AppColors.mint,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(_isEditing ? 'Update Bill' : 'Save Bill'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final biller = _billerCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text);
    final messenger = ScaffoldMessenger.of(context);
    if (name.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    if (biller.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Biller is required')),
      );
      return;
    }
    if (amount == null || amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    final store = context.read<BillStore>();
    final initial = widget.initial;
    final last4 = _last4Ctrl.text.trim().isEmpty ? null : _last4Ctrl.text.trim();
    final bill = Bill(
      id: initial?.id ?? 'bill-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      biller: biller,
      amount: amount,
      dueDate: _dueDate,
      status: initial?.status ?? BillStatus.upcoming,
      iconKind: _iconKind,
      accountLast4: last4,
      autoPay: _autoPay,
      billingPeriodStart: initial?.billingPeriodStart,
      billingPeriodEnd: initial?.billingPeriodEnd,
      paymentHistory: initial?.paymentHistory ?? const [],
    );
    await store.upsert(bill);
    if (mounted) Navigator.of(context).pop();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
