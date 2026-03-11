// ignore_for_file: deprecated_member_use

import 'package:expense_tracker_offline/presentation/screens/category_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../data/models/expense_model.dart';

import '../blocs/expense_cubit.dart';
import '../blocs/category_cubit.dart';
import '../blocs/shortcut_cubit.dart';
import '../../data/models/shortcut_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;
  final bool forceRecurringMode;

  const AddExpenseScreen({
    super.key,
    this.expense,
    this.forceRecurringMode = false,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TransactionType _type = TransactionType.expense;
  RecurrenceType _recurrence = RecurrenceType.none;

  @override
  void initState() {
    super.initState();
    // Pre-select the first category if available or use existing expense data
    final categories = context.read<CategoryCubit>().state;

    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _noteController.text = widget.expense!.note;
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedDate = widget.expense!.date;
      _type = widget.expense!.type;
      _recurrence = widget.expense!.recurrence ?? RecurrenceType.none;
    } else if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
      if (widget.forceRecurringMode) {
        _recurrence = RecurrenceType.monthly;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final amountText = _amountController.text;
    if (amountText.isEmpty || _selectedCategoryId == null) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final newExpense = ExpenseModel(
      id: widget.expense?.id ?? const Uuid().v4(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      note: _noteController.text.trim(),
      date: _selectedDate,
      type: _type,
      recurrence: _recurrence,
    );

    context.read<ExpenseCubit>().addExpense(newExpense);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: oneYearAgo,
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        // Keep the time, just update the date part if needed, or just use the date.
        // Requirement says "full details" DateTime object.
        // Let's keep the current time for chronological sorting within the day.
        final time = DateTime.now();
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          time.hour,
          time.minute,
          time.second,
        );
      });
    }
  }

  void _applyShortcut(ShortcutModel shortcut) {
    setState(() {
      _amountController.text = shortcut.amount.toString();
      _selectedCategoryId = shortcut.categoryId;
      if (shortcut.note != null) {
        _noteController.text = shortcut.note!;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied shortcut: ${shortcut.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showAddShortcutDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    // Check local variables for current state
    String? currentCatId = _selectedCategoryId;

    // If user has already filled some data, pre-fill the shortcut dialog
    if (_amountController.text.isNotEmpty) {
      amountController.text = _amountController.text;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title (e.g. Coffee)',
              ),
              autofocus: true,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Default Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  amountController.text.isEmpty ||
                  currentCatId == null) {
                return;
              }

              final newShortcut = ShortcutModel(
                id: const Uuid().v4(),
                title: titleController.text.trim(),
                amount: double.tryParse(amountController.text) ?? 0,
                categoryId: currentCatId,
                note: _noteController.text.isNotEmpty
                    ? _noteController.text
                    : null,
              );

              context.read<ShortcutCubit>().addShortcut(newShortcut);
              Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state;
    final shortcuts = context.watch<ShortcutCubit>().state;

    // Safety check if categories are still loading or empty
    if (categories.isNotEmpty && _selectedCategoryId == null) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null
              ? (widget.forceRecurringMode ? 'New Recurring' : 'New Transaction')
              : 'Edit Transaction',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Selector
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Expense',
                        isSelected: _type == TransactionType.expense,
                        color: Colors.redAccent,
                        onTap: () => setState(() => _type = TransactionType.expense),
                      ),
                    ),
                    Expanded(
                      child: _TypeButton(
                        label: 'Income',
                        isSelected: _type == TransactionType.income,
                        color: Colors.greenAccent[700]!,
                        onTap: () => setState(() => _type = TransactionType.income),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // Recurring Options (if applicable)
              if (widget.forceRecurringMode ||
                  (widget.expense != null &&
                      widget.expense?.recurrence != RecurrenceType.none)) ...[
                const Text(
                  'RECURRENCE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const Gap(12),
                Row(
                  children: [
                    _RecurrenceChip(
                      label: 'Weekly',
                      isSelected: _recurrence == RecurrenceType.weekly,
                      onTap: () => setState(() => _recurrence = RecurrenceType.weekly),
                    ),
                    const Gap(12),
                    _RecurrenceChip(
                      label: 'Monthly',
                      isSelected: _recurrence == RecurrenceType.monthly,
                      onTap: () => setState(() => _recurrence = RecurrenceType.monthly),
                    ),
                  ],
                ),
                const Gap(32),
              ],

              // Amount Input
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Text('AMOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const Gap(12),
                    TextField(
                      controller: _amountController,
                      autofocus: widget.expense == null,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _type == TransactionType.income
                            ? Colors.greenAccent[700]
                            : Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -1.5,
                      ),
                      decoration: InputDecoration(
                        prefixText: 'ETB ',
                        prefixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // Category Selection
              const Text('CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const Gap(12),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length + 1,
                  separatorBuilder: (ctx, i) => const Gap(12),
                  itemBuilder: (ctx, index) {
                    if (index == categories.length) {
                      return _CategoryChip(
                        label: 'Manage',
                        icon: Icons.settings_outlined,
                        isSelected: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => const CategoryManagementScreen()),
                        ),
                        isSpecial: true,
                      );
                    }

                    final cat = categories[index];
                    return _CategoryChip(
                      label: cat.name,
                      iconCode: cat.iconCode,
                      isSelected: cat.id == _selectedCategoryId,
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                    );
                  },
                ),
              ),

              const Gap(32),

              // Note & Date
              Row(
                children: [
                  Expanded(
                    child: _InputContainer(
                      onTap: _presentDatePicker,
                      icon: Icons.calendar_today_rounded,
                      label: DateFormat('MMM d, y').format(_selectedDate),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          hintText: 'Note...',
                          border: InputBorder.none,
                          icon: Icon(Icons.edit_note_rounded, size: 20, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(32),

              // Shortcuts
              if (widget.expense == null && shortcuts.isNotEmpty) ...[
                const Text('QUICK SHORTCUTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const Gap(12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ...shortcuts.map((shortcut) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ActionChip(
                          label: Text(shortcut.title),
                          avatar: const Icon(Icons.bolt, size: 16),
                          onPressed: () => _applyShortcut(shortcut),
                        ),
                      )),
                      ActionChip(
                        label: const Text('New'),
                        avatar: const Icon(Icons.add_rounded, size: 16),
                        onPressed: _showAddShortcutDialog,
                      ),
                    ],
                  ),
                ),
                const Gap(40),
              ] else if (widget.expense == null) ...[
                OutlinedButton.icon(
                  onPressed: _showAddShortcutDialog,
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('Add Quick Shortcut'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const Gap(40),
              ],

              // Save Button
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  widget.expense == null ? 'Save Transaction' : 'Update Transaction',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _RecurrenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InputContainer extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const _InputContainer({required this.onTap, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int? iconCode;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSpecial;

  const _CategoryChip({
    required this.label,
    this.iconCode,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withOpacity(isSelected ? 1 : 0.4),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? IconData(iconCode!, fontFamily: 'MaterialIcons'),
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
