import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../data/models/expense_model.dart';
import '../../blocs/expense_cubit.dart';
import '../../blocs/category_cubit.dart';
import '../../screens/add_expense_screen.dart';

class RecurringExpenseTile extends StatelessWidget {
  final ExpenseModel expense;

  const RecurringExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final category = context.read<CategoryCubit>().getCategoryById(expense.categoryId);
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ');
    final isIncome = expense.type == TransactionType.income;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        child: Icon(
          category != null
              ? IconData(
                  category.iconCode,
                  fontFamily: 'Lucide',
                  fontPackage: 'lucide_icons_flutter',
                )
              : Icons.category,
          color: isIncome ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        category?.name ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expense.note.isNotEmpty)
            Text(
              expense.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          Row(
            children: [
              Icon(
                expense.recurrence == RecurrenceType.weekly ? Icons.repeat : Icons.calendar_month,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(4),
              Text(
                expense.recurrence == RecurrenceType.weekly ? 'Weekly' : 'Monthly',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currencyFormat.format(expense.amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
          ),
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => AddExpenseScreen(expense: expense))),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recurring?'),
        content: const Text('This will stop future transactions from being generated. Past transactions will remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<ExpenseCubit>().deleteExpense(expense.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
