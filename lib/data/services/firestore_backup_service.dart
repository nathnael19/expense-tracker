import 'package:cloud_firestore/cloud_firestore.dart';
import '../local/storage_service.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/shortcut_model.dart';
import '../models/debt_model.dart';
import '../models/budget_model.dart';

class FirestoreBackupService {
  static final FirestoreBackupService _instance =
      FirestoreBackupService._internal();
  factory FirestoreBackupService() => _instance;
  FirestoreBackupService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _backupCollection = 'backups';
  static const String _timestampKey = 'last_backup_timestamp';

  /// Upload all local data to Firestore
  Future<bool> uploadBackup(String userId) async {
    try {
      final data = await _exportAllData();

      await _firestore.collection(_backupCollection).doc(userId).set(data);

      await _setLastBackupTime(DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Download backup from Firestore
  Future<Map<String, dynamic>?> downloadBackup(String userId) async {
    try {
      final doc = await _firestore
          .collection(_backupCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Restore data from Firestore backup
  Future<bool> restoreBackup(String userId) async {
    try {
      final data = await downloadBackup(userId);
      if (data == null) {
        return false;
      }

      await _importAllData(data);
      await _setLastBackupTime(DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get last backup timestamp
  Future<DateTime?> getLastBackupTime() async {
    final timestamp = StorageService.settingsBox.get(_timestampKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp as String);
  }

  /// Export all data from local storage
  Future<Map<String, dynamic>> _exportAllData() async {
    return {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'expenses': StorageService.expenseBox.values
          .map(
            (e) => {
              'id': e.id,
              'amount': e.amount,
              'categoryId': e.categoryId,
              'note': e.note,
              'date': e.date.toIso8601String(),
              'type': e.type.index,
              'recurrence': e.recurrence?.index,
              'lastGeneratedDate': e.lastGeneratedDate?.toIso8601String(),
            },
          )
          .toList(),
      'categories': StorageService.categoryBox.values
          .map((c) => {'id': c.id, 'name': c.name, 'iconCode': c.iconCode})
          .toList(),
      'shortcuts': StorageService.shortcutBox.values
          .map(
            (s) => {
              'id': s.id,
              'title': s.title,
              'amount': s.amount,
              'categoryId': s.categoryId,
              'note': s.note,
            },
          )
          .toList(),
      'debts': StorageService.debtBox.values
          .map(
            (d) => {
              'id': d.id,
              'personName': d.personName,
              'amount': d.amount,
              'note': d.note,
              'date': d.date.toIso8601String(),
              'dueDate': d.dueDate?.toIso8601String(),
              'type': d.type.index,
              'isPaid': d.isPaid,
            },
          )
          .toList(),
      'budgets': StorageService.budgetBox.values
          .map(
            (b) => {
              'id': b.id,
              'categoryId': b.categoryId,
              'amount': b.amount,
              'month': b.month,
              'year': b.year,
            },
          )
          .toList(),
    };
  }

  /// Import all data to local storage
  Future<void> _importAllData(Map<String, dynamic> data) async {
    // Clear existing data
    await StorageService.expenseBox.clear();
    await StorageService.categoryBox.clear();
    await StorageService.shortcutBox.clear();
    await StorageService.debtBox.clear();
    await StorageService.budgetBox.clear();

    // Import expenses
    final expenses = data['expenses'] as List<dynamic>? ?? [];
    for (var expenseData in expenses) {
      final expense = _expenseFromJson(expenseData as Map<String, dynamic>);
      await StorageService.expenseBox.put(expense.id, expense);
    }

    // Import categories
    final categories = data['categories'] as List<dynamic>? ?? [];
    for (var categoryData in categories) {
      final category = _categoryFromJson(categoryData as Map<String, dynamic>);
      await StorageService.categoryBox.put(category.id, category);
    }

    // Import shortcuts
    final shortcuts = data['shortcuts'] as List<dynamic>? ?? [];
    for (var shortcutData in shortcuts) {
      final shortcut = _shortcutFromJson(shortcutData as Map<String, dynamic>);
      await StorageService.shortcutBox.put(shortcut.id, shortcut);
    }

    // Import debts
    final debts = data['debts'] as List<dynamic>? ?? [];
    for (var debtData in debts) {
      final debt = _debtFromJson(debtData as Map<String, dynamic>);
      await StorageService.debtBox.put(debt.id, debt);
    }

    // Import budgets
    final budgets = data['budgets'] as List<dynamic>? ?? [];
    for (var budgetData in budgets) {
      final budget = _budgetFromJson(budgetData as Map<String, dynamic>);
      await StorageService.budgetBox.put(budget.id, budget);
    }
  }

  /// Set last backup timestamp
  Future<void> _setLastBackupTime(DateTime time) async {
    await StorageService.settingsBox.put(_timestampKey, time.toIso8601String());
  }

  // Helper methods to convert JSON to models
  ExpenseModel _expenseFromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      note: json['note'] as String,
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.values[json['type'] as int],
      recurrence: json['recurrence'] != null
          ? RecurrenceType.values[json['recurrence'] as int]
          : null,
      lastGeneratedDate: json['lastGeneratedDate'] != null
          ? DateTime.parse(json['lastGeneratedDate'] as String)
          : null,
    );
  }

  CategoryModel _categoryFromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as int,
    );
  }

  ShortcutModel _shortcutFromJson(Map<String, dynamic> json) {
    return ShortcutModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
    );
  }

  DebtModel _debtFromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      personName: json['personName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isPaid: json['isPaid'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      type: DebtType.values[json['type'] as int],
    );
  }

  BudgetModel _budgetFromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      categoryId: json['categoryId'] as String?,
    );
  }
}
