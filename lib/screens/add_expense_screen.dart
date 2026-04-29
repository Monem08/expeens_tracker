import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart' as model;
import '../state/transaction_store.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/category_picker_sheet.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.initial});

  /// When provided, the screen edits an existing transaction instead of
  /// creating a new one; the amount, category, date and note are prefilled
  /// and saving upserts the row (same id).
  final model.Transaction? initial;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late ExpenseCategory _category;
  late DateTime _date;
  late bool _isIncome;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _category = initial?.category ?? ExpenseCategory.food;
    _date = initial?.date ?? DateTime.now();
    _isIncome = initial?.isIncome ?? false;
    _amountCtrl = TextEditingController(
      text: initial == null ? '' : initial.amount.abs().toStringAsFixed(2),
    );
    _noteCtrl = TextEditingController(text: initial?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit entry' : 'New entry',
          style: TextStyle(
            color: AppColors.mint,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _TypeToggle(
            isIncome: _isIncome,
            onChanged: (v) => setState(() {
              _isIncome = v;
              if (v && _category != ExpenseCategory.income) {
                _category = ExpenseCategory.income;
              } else if (!v && _category == ExpenseCategory.income) {
                _category = ExpenseCategory.food;
              }
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  _isIncome ? 'AMOUNT EARNED' : 'AMOUNT SPENT',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$',
                      style: GoogleFonts.inter(
                        color: AppColors.mint,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _amountCtrl,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          _SingleDecimalFormatter(),
                        ],
                        style: GoogleFonts.inter(
                          color: AppColors.mint,
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.mint.withValues(alpha: 0.35),
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 1,
                  width: 180,
                  color: AppColors.mint.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: _pickCategoryFromAll,
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppColors.mint,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final c in const [
                ExpenseCategory.food,
                ExpenseCategory.travel,
                ExpenseCategory.shopping,
                ExpenseCategory.fun,
              ])
                CategoryChip(
                  category: c,
                  selected: c == _category,
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'DATE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
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
                      DateFormat('MM/dd/yyyy').format(_date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NOTES',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What was this for?',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 56, left: 8),
                child: Icon(Icons.edit_note_outlined, color: AppColors.mint),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              _isEditing
                  ? 'Update'
                  : _isIncome
                  ? 'Save Income'
                  : 'Save Expense',
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCategoryFromAll() async {
    final picked = await showCategoryPicker(context, selected: _category);
    if (picked != null) {
      setState(() {
        _category = picked;
        _isIncome = picked == ExpenseCategory.income;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final rawAmount = double.tryParse(_amountCtrl.text);
    if (rawAmount == null || rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    final signed = _isIncome ? rawAmount : -rawAmount;
    final note = _noteCtrl.text.trim();
    // When editing, preserve the original title if it looks custom
    // (i.e. not just the old category's auto-generated label) and the
    // user hasn't touched the note. If the user actually edited the note
    // (or it's a new transaction), the note becomes the new title, matching
    // the create flow. Otherwise fall back to the current category label.
    final existing = widget.initial;
    final hadCustomTitle =
        existing != null && existing.title != existing.category.label;
    final noteChanged = existing == null || note != (existing.note ?? '');
    final String title;
    if (hadCustomTitle && !noteChanged) {
      title = existing.title;
    } else if (note.isNotEmpty) {
      title = note;
    } else {
      title = _category.label;
    }
    final tx = model.Transaction(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      amount: signed,
      date: _date,
      note: note.isEmpty ? null : note,
    );
    final store = context.read<TransactionStore>();
    if (_isEditing) {
      await store.update(tx);
    } else {
      await store.add(tx);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Expense updated' : 'Expense saved')),
    );
    Navigator.of(context).pop();
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.isIncome, required this.onChanged});

  final bool isIncome;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TogglePill(
              label: 'Expense',
              icon: Icons.trending_down,
              selected: !isIncome,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _TogglePill(
              label: 'Income',
              icon: Icons.trending_up,
              selected: isIncome,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.mint : Colors.transparent;
    final fg = selected ? AppColors.onMint : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SingleDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if ('.'.allMatches(text).length <= 1) return newValue;
    return oldValue;
  }
}
