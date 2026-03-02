import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../blocs/expense_cubit.dart';
import '../common/smart_empty_state.dart';
import 'transaction_item_card.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
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
            return TransactionItemCard(expense: expense);
          },
        );
      },
    );
  }
}
