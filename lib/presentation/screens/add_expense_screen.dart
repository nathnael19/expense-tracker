// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/expense_model.dart';
import '../../data/models/shortcut_model.dart';
import '../blocs/expense_cubit.dart';
import '../blocs/category_cubit.dart';
import '../blocs/shortcut_cubit.dart';

import '../components/add_expense/transaction_type_selector.dart';
import '../components/add_expense/recurrence_selector.dart';
import '../components/add_expense/amount_input_field.dart';
import '../components/add_expense/category_selector_list.dart';
import '../components/add_expense/date_note_inputs.dart';
import '../components/add_expense/shortcut_section.dart';
import '../components/add_expense/add_shortcut_dialog.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;
  final bool forceRecurringMode;

  const AddExpenseScreen({super.key, this.expense, this.forceRecurringMode = false});

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
      if (widget.forceRecurringMode) _recurrence = RecurrenceType.monthly;
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
    Navigator.of(context).pop();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(now.year - 1), lastDate: now);
    if (pickedDate != null) {
      setState(() {
        final time = DateTime.now();
        _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, time.hour, time.minute, time.second);
      });
    }
  }

  void _applyShortcut(ShortcutModel shortcut) {
    setState(() {
      _amountController.text = shortcut.amount.toString();
      _selectedCategoryId = shortcut.categoryId;
      if (shortcut.note != null) _noteController.text = shortcut.note!;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied shortcut: ${shortcut.title}'), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state;
    final shortcuts = context.watch<ShortcutCubit>().state;
    if (categories.isNotEmpty && _selectedCategoryId == null) _selectedCategoryId = categories.first.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? (widget.forceRecurringMode ? 'New Recurring' : 'New Transaction') : 'Edit Transaction', style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TransactionTypeSelector(currentType: _type, onTypeChanged: (type) => setState(() => _type = type)),
              const Gap(32),
              if (widget.forceRecurringMode || (widget.expense != null && widget.expense?.recurrence != RecurrenceType.none)) ...[
                RecurrenceSelector(currentRecurrence: _recurrence, onRecurrenceChanged: (r) => setState(() => _recurrence = r)),
                const Gap(32),
              ],
              AmountInputField(controller: _amountController, autofocus: widget.expense == null, transactionType: _type),
              const Gap(32),
              CategorySelectorList(categories: categories, selectedCategoryId: _selectedCategoryId, onCategorySelected: (id) => setState(() => _selectedCategoryId = id)),
              const Gap(32),
              DateNoteInputs(selectedDate: _selectedDate, onDatePickerTap: _presentDatePicker, noteController: _noteController),
              const Gap(32),
              ShortcutSection(
                shortcuts: shortcuts,
                onShortcutApplied: _applyShortcut,
                onAddShortcut: () => showDialog(context: context, builder: (ctx) => AddShortcutDialog(initialCategoryId: _selectedCategoryId, initialAmount: _amountController.text, initialNote: _noteController.text)),
                isEditMode: widget.expense != null,
              ),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                child: Text(widget.expense == null ? 'Save Transaction' : 'Update Transaction', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}
