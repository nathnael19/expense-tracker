import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../blocs/expense_cubit.dart';
import '../blocs/category_cubit.dart';
import 'add_expense_screen.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions'), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  const AddExpenseScreen(forceRecurringMode: true),
            ),
          );
        },
        label: const Text('Add Recurring'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          final recurringExpenses = state.allExpenses
              .where(
                (e) =>
                    (e.recurrence ?? RecurrenceType.none) !=
                    RecurrenceType.none,
              )
              .toList();

          if (recurringExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),
                  const Gap(16),
                  Text(
                    'No recurring transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: recurringExpenses.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (ctx, index) {
              final expense = recurringExpenses[index];
              return _RecurringExpenseTile(expense: expense);
            },
          );
        },
      ),
    );
  }
}

class _RecurringExpenseTile extends StatelessWidget {
  final ExpenseModel expense;

  const _RecurringExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final category = context.read<CategoryCubit>().getCategoryById(
      expense.categoryId,
    );
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ');
    final isIncome = expense.type == TransactionType.income;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        child: Icon(
          category != null
              ? IconData(category.iconCode, fontFamily: 'MaterialIcons')
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          Row(
            children: [
              Icon(
                expense.recurrence == RecurrenceType.weekly
                    ? Icons.repeat
                    : Icons.calendar_month,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(4),
              Text(
                expense.recurrence == RecurrenceType.weekly
                    ? 'Weekly'
                    : 'Monthly',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => AddExpenseScreen(expense: expense),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recurring?'),
        content: const Text(
          'This will stop future transactions from being generated. Past transactions will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
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
