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
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Pre-select the first category if available
    final categories = context.read<CategoryCubit>().state;
    if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
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
      id: const Uuid().v4(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      note: _noteController.text.trim(),
      date: _selectedDate,
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
        title: const Text('Add Expense'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 0. Shortcuts Section
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Add Shortcut'),
                      onPressed: _showAddShortcutDialog,
                    ),
                    const Gap(8),
                    ...shortcuts.map((shortcut) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InputChip(
                          label: Text(shortcut.title),
                          onPressed: () => _applyShortcut(shortcut),
                          onDeleted: () {
                            context.read<ShortcutCubit>().deleteShortcut(
                              shortcut.id,
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Gap(16),

              const Gap(16),

              // 1. Amount Input (Primary Focus)
              TextField(
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: 'ETB ',
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ),

              const Gap(24),

              // 2. Category Selection
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      categories.length +
                      1, // +1 for "Edit/Manage" trigger if we wanted, but let's stick to list
                  separatorBuilder: (ctx, i) => const Gap(8),
                  itemBuilder: (ctx, index) {
                    if (index == categories.length) {
                      // Placeholder for managing categories later
                      return _CategoryChip(
                        label: 'Manage',
                        icon: Icons.settings,
                        isSelected: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  const CategoryManagementScreen(),
                            ),
                          );
                        },
                        isSpecial: true,
                      );
                    }

                    final cat = categories[index];
                    final isSelected = cat.id == _selectedCategoryId;
                    return _CategoryChip(
                      label: cat.name,
                      iconCode: cat.iconCode,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                      },
                    );
                  },
                ),
              ),

              const Gap(24),

              // 3. Date & Note
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _presentDatePicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const Gap(8),
                            Flexible(
                              child: Text(
                                DateFormat.yMMMd().format(_selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Note...',
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.edit,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(40),

              // 4. Save Button
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(32),
            ],
          ),
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
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : (isSpecial
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5));
    final textColor = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Icon(
              icon ?? IconData(iconCode!, fontFamily: 'MaterialIcons'),
              size: 18,
              color: textColor,
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
