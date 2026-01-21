import '../local/storage_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final StorageService _storageService = StorageService();

  Future<void> addExpense(ExpenseModel expense) async {
    await _storageService.addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _storageService.deleteExpense(id);
  }

  List<ExpenseModel> getAllExpenses() {
    return _storageService.getAllExpenses();
  }

  // Clean all data (mainly for testing/debugging)
  Future<void> clearAll() async {
    await _storageService.clearAllExpenses();
  }
}
