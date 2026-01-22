import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseState {
  final List<ExpenseModel> allExpenses;
  final List<ExpenseModel> todaysExpenses;
  final double todaysTotal;
  final double todaysIncome;
  final double todaysNetBalance;

  ExpenseState({
    required this.allExpenses,
    required this.todaysExpenses,
    required this.todaysTotal,
    required this.todaysIncome,
    required this.todaysNetBalance,
  });

  factory ExpenseState.initial() {
    return ExpenseState(
      allExpenses: [],
      todaysExpenses: [],
      todaysTotal: 0,
      todaysIncome: 0,
      todaysNetBalance: 0,
    );
  }
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository = ExpenseRepository();

  ExpenseCubit() : super(ExpenseState.initial()) {
    // Small delay to allow initial build to complete
    Future.delayed(const Duration(milliseconds: 100), () {
      _initialLoad();
    });
  }

  Future<void> _initialLoad() async {
    await _processRecurringTransactions();
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

    double totalExpense = 0.0;
    double totalIncome = 0.0;

    for (var e in today) {
      if (e.type == TransactionType.income) {
        totalIncome += e.amount;
      } else {
        totalExpense += e.amount;
      }
    }

    emit(
      ExpenseState(
        allExpenses: all,
        todaysExpenses: today,
        todaysTotal: totalExpense,
        todaysIncome: totalIncome,
        todaysNetBalance: totalIncome - totalExpense,
      ),
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

  Future<void> _processRecurringTransactions() async {
    final all = _repository.getAllExpenses();
    final recurring = all
        .where(
          (e) => (e.recurrence ?? RecurrenceType.none) != RecurrenceType.none,
        )
        .toList();
    final now = DateTime.now();
    bool updated = false;

    for (var e in recurring) {
      DateTime lastDate = e.lastGeneratedDate ?? e.date;
      DateTime nextDate;

      if (e.recurrence == RecurrenceType.weekly) {
        nextDate = lastDate.add(const Duration(days: 7));
      } else {
        // Monthly
        nextDate = DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      }

      // Check if nextDate is in the past or today
      while (nextDate.isBefore(now) ||
          (nextDate.year == now.year &&
              nextDate.month == now.month &&
              nextDate.day == now.day)) {
        // Create new transaction
        final newId = const Uuid().v4();
        final newExpense = e.copyWith(
          id: newId,
          date: nextDate,
          recurrence: RecurrenceType
              .none, // Children are not recurring templates themselves
          lastGeneratedDate: null,
        );

        await _repository.addExpense(newExpense);

        // Update the template's lastGeneratedDate
        final updatedTemplate = e.copyWith(lastGeneratedDate: nextDate);
        await _repository.addExpense(updatedTemplate);

        e = updatedTemplate; // Update reference for while loop

        if (e.recurrence == RecurrenceType.weekly) {
          nextDate = nextDate.add(const Duration(days: 7));
        } else {
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        }
        updated = true;
      }
    }

    if (updated) {
      // No need to call loadExpenses() here as it's called after _processRecurringTransactions
    }
  }
}
