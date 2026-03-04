// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../blocs/expense_cubit.dart';
import '../blocs/stats_cubit.dart';
import '../blocs/budget_cubit.dart';
import '../components/common/summary_card.dart';
import '../components/home/home_app_bar.dart';
import '../components/home/transaction_list.dart';
import '../screens/add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(16),
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
              const Expanded(
                child: TransactionList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AddExpenseScreen()));
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
