import 'package:expense_tracker_offline/data/models/budget_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/shortcut_model.dart';
import '../models/debt_model.dart';

class StorageService {
  static const String expenseBoxName = 'expenses';
  static const String categoryBoxName = 'categories';
  static const String shortcutBoxName = 'shortcuts';
  static const String settingsBoxName = 'settings';
  static const String debtBoxName = 'debts';
  static const String budgetBoxName = 'budgets';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(ShortcutModelAdapter());
    Hive.registerAdapter(DebtModelAdapter());
    Hive.registerAdapter(DebtTypeAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(BudgetModelAdapter());

    await Hive.openBox<ExpenseModel>(expenseBoxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<ShortcutModel>(shortcutBoxName);
    await Hive.openBox<DebtModel>(debtBoxName);
    await Hive.openBox<BudgetModel>(budgetBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<ExpenseModel> get expenseBox =>
      Hive.box<ExpenseModel>(expenseBoxName);
  static Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);
  static Box<ShortcutModel> get shortcutBox =>
      Hive.box<ShortcutModel>(shortcutBoxName);
  static Box<DebtModel> get debtBox => Hive.box<DebtModel>(debtBoxName);
  static Box<BudgetModel> get budgetBox => Hive.box<BudgetModel>(budgetBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  // Helper methods for Expenses
  Future<void> addExpense(ExpenseModel expense) async {
    await expenseBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await expenseBox.delete(id);
  }

  List<ExpenseModel> getAllExpenses() {
    return expenseBox.values.toList();
  }

  Future<void> clearAllExpenses() async {
    await expenseBox.clear();
  }

  // Helper methods for Categories
  Future<void> addCategory(CategoryModel category) async {
    await categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await categoryBox.delete(id);
  }

  List<CategoryModel> getAllCategories() {
    return categoryBox.values.toList();
  }
}
