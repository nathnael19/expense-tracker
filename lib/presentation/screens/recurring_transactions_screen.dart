import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../data/models/expense_model.dart';
import '../blocs/expense_cubit.dart';
import '../screens/add_expense_screen.dart';
import '../components/recurring/recurring_expense_tile.dart';

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
              builder: (ctx) => const AddExpenseScreen(forceRecurringMode: true),
            ),
          );
        },
        label: const Text('Add Recurring'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          final recurringExpenses = state.allExpenses
              .where((e) => (e.recurrence ?? RecurrenceType.none) != RecurrenceType.none)
              .toList();

          if (recurringExpenses.isEmpty) return _buildEmptyState(context);

          return ListView.separated(
            itemCount: recurringExpenses.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (ctx, index) => RecurringExpenseTile(expense: recurringExpenses[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
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
}
