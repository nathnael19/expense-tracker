import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/category_model.dart';
import '../../blocs/expense_cubit.dart';
import '../../blocs/category_cubit.dart';
import '../../screens/add_expense_screen.dart';

class TransactionItemCard extends StatelessWidget {
  final ExpenseModel expense;
  const TransactionItemCard({super.key, required this.expense});

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
