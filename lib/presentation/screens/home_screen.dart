// ignore_for_file: deprecated_member_use

import 'package:expense_tracker_offline/data/models/expense_model.dart';
import 'package:expense_tracker_offline/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../blocs/expense_cubit.dart';
import '../blocs/category_cubit.dart';
import '../blocs/stats_cubit.dart';
import '../blocs/budget_cubit.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';
import 'monthly_report_screen.dart';
import 'settings_screen.dart';
import 'debt_screen.dart';
import '../widgets/streak_indicator.dart';
import '../widgets/smart_empty_state.dart';
import 'shopping_lists_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Dashboard',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const Gap(8),
                // Use selector for streak
                BlocSelector<StatsCubit, StatsState, int>(
                  selector: (state) => state.streak,
                  builder: (context, streak) => StreakIndicator(streak: streak),
                ),
              ],
            ),
            Text(
              DateFormat.yMMMMd().format(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.handshake_outlined,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => const DebtScreen()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ShoppingListsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.bar_chart,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const MonthlyReportScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(16),
              // Use Selector for SummaryCard data
              Builder(builder: (context) {
                final expenseState = context.select<ExpenseCubit, ExpenseState>((c) => c.state);
                final budgetState = context.select<BudgetCubit, BudgetState>((c) => c.state);
                final statsState = context.select<StatsCubit, StatsState>((c) => c.state);

                return SummaryCard(
                  todaysTotal: expenseState.todaysTotal,
                  todaysIncome: expenseState.todaysIncome,
                  todaysNetBalance: expenseState.todaysNetBalance,
                  monthlyTotal: statsState.reportStats.totalSpent,
                  monthlyBudget: budgetState.monthlyBudget?.amount,
                );
              }),
              const Gap(32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  BlocSelector<ExpenseCubit, ExpenseState, bool>(
                    selector: (state) => state.todaysExpenses.isNotEmpty,
                    builder: (context, hasExpenses) => hasExpenses
                        ? Text(
                            'Today',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  buildWhen: (prev, curr) => prev.todaysExpenses != curr.todaysExpenses,
                  builder: (context, state) {
                    final todaysExpenses = state.todaysExpenses;
                    if (todaysExpenses.isEmpty) {
                      return const SmartEmptyState(type: EmptyStateType.home);
                    }
                    return ListView.separated(
                      itemCount: todaysExpenses.length,
                      separatorBuilder: (ctx, i) => const Gap(12),
                      itemBuilder: (ctx, index) {
                        final expense = todaysExpenses[index];
                        return _TransactionItem(expense: expense);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const AddExpenseScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final ExpenseModel expense;
  const _TransactionItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, List<CategoryModel>>(
      builder: (context, categories) {
        final category = categories.where((c) => c.id == expense.categoryId).firstOrNull ??
            (categories.isNotEmpty ? categories.first : null);

        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) {
            context.read<ExpenseCubit>().deleteExpense(expense.id);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Expense deleted'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    context.read<ExpenseCubit>().addExpense(expense);
                  },
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => AddExpenseScreen(expense: expense),
                  ),
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (category != null
                              ? Colors.primaries[category.name.hashCode.abs() % Colors.primaries.length]
                              : Colors.grey)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category != null
                          ? IconData(
                              category.iconCode,
                              fontFamily: 'Lucide',
                              fontPackage: 'lucide_icons_flutter',
                            )
                          : Icons.category,
                      color: category != null
                          ? Colors.primaries[category.name.hashCode.abs() % Colors.primaries.length]
                          : Colors.grey,
                      size: 24,
                    ),
                  ),
                  if ((expense.recurrence ?? RecurrenceType.none) != RecurrenceType.none)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.repeat,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                category?.name ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: expense.note.isNotEmpty
                  ? Text(
                      expense.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    )
                  : null,
              trailing: Text(
                '${expense.type == TransactionType.income ? '+' : '-'}ETB ${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: expense.type == TransactionType.income ? Colors.greenAccent[400] : Colors.redAccent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
