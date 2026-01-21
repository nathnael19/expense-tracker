import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/storage_service.dart';
import '../../data/models/budget_model.dart';

class BudgetState {
  final BudgetModel? monthlyBudget;
  final List<BudgetModel> categoryBudgets;

  BudgetState({this.monthlyBudget, this.categoryBudgets = const []});

  BudgetState copyWith({
    BudgetModel? monthlyBudget,
    List<BudgetModel>? categoryBudgets,
  }) {
    return BudgetState(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }
}

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit() : super(BudgetState()) {
    loadBudgets();
  }

  void loadBudgets() {
    final now = DateTime.now();
    final allBudgets = StorageService.budgetBox.values
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();

    final monthly = allBudgets.where((b) => b.categoryId == null).firstOrNull;
    final categories = allBudgets.where((b) => b.categoryId != null).toList();

    emit(BudgetState(monthlyBudget: monthly, categoryBudgets: categories));
  }

  Future<void> setMonthlyBudget(double amount) async {
    final now = DateTime.now();
    final id = '${now.year}-${now.month}';
    final budget = BudgetModel(
      id: id,
      amount: amount,
      month: now.month,
      year: now.year,
    );

    await StorageService.budgetBox.put(id, budget);
    loadBudgets();
  }

  Future<void> setCategoryBudget(String categoryId, double amount) async {
    final now = DateTime.now();
    final id = '${now.year}-${now.month}-$categoryId';
    final budget = BudgetModel(
      id: id,
      amount: amount,
      month: now.month,
      year: now.year,
      categoryId: categoryId,
    );

    await StorageService.budgetBox.put(id, budget);
    loadBudgets();
  }

  Future<void> deleteCategoryBudget(String categoryId) async {
    final now = DateTime.now();
    final id = '${now.year}-${now.month}-$categoryId';
    await StorageService.budgetBox.delete(id);
    loadBudgets();
  }
}
