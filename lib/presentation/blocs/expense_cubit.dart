import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseState {
  final List<ExpenseModel> allExpenses;
  final List<ExpenseModel> todaysExpenses;
  final double todaysTotal;

  ExpenseState({
    required this.allExpenses,
    required this.todaysExpenses,
    required this.todaysTotal,
  });

  factory ExpenseState.initial() {
    return ExpenseState(allExpenses: [], todaysExpenses: [], todaysTotal: 0);
  }
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository = ExpenseRepository();

  ExpenseCubit() : super(ExpenseState.initial()) {
    loadExpenses();
  }

  void loadExpenses() {
    final all = _repository.getAllExpenses()
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    final today = all.where((e) {
      return e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day;
    }).toList();

    final total = today.fold(0.0, (sum, item) => sum + item.amount);

    emit(
      ExpenseState(allExpenses: all, todaysExpenses: today, todaysTotal: total),
    );
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _repository.addExpense(expense);
    loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    loadExpenses();
  }
}
