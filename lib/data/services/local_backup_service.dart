import 'dart:convert';
import 'dart:io';
import 'package:expense_tracker_offline/data/local/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/shortcut_model.dart';
import '../models/debt_model.dart';
import '../models/budget_model.dart';
import '../models/shopping_list_model.dart';
import '../models/shopping_item_model.dart';
import '../models/person_model.dart';

class LocalBackupService {
  static final LocalBackupService _instance = LocalBackupService._internal();
  factory LocalBackupService() => _instance;
  LocalBackupService._internal();

  static const String _backupFileName = 'expense_tracker_local_backup.json';
  static const String _timestampKey = 'last_local_backup_timestamp';

  /// Generate a temporary backup file and return its path
  Future<String?> createBackupFile() async {
    try {
      final data = await _exportAllData();
      final jsonData = jsonEncode(data);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_backupFileName');
      await file.writeAsString(jsonData);

      return file.path;
    } catch (e) {
      debugPrint('LOCAL_BACKUP_SERVICE createBackupFile ERROR: $e');
      return null;
    }
  }

  /// Check if a local backup exists (now just checks for the last timestamp for UI)
  Future<bool> backupExists() async {
    // With the new share/picker approach, we can't easily check if the file still exists
    // where the user saved it, but we can check if they've ever made one.
    return await getLastBackupTime() != null;
  }

  /// Restore data from a specific file path (APPEND logic)
  Future<bool> restoreBackupFromFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return false;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      await _importAllData(data);
      await _setLastBackupTime(DateTime.now());
      return true;
    } catch (e) {
      debugPrint('LOCAL_BACKUP_SERVICE restoreBackupFromFile ERROR: $e');
      return false;
    }
  }

  /// Set last backup time
  Future<void> setLastBackupTime(DateTime time) async {
    await _setLastBackupTime(time);
  }

  /// Get the last backup timestamp
  Future<DateTime?> getLastBackupTime() async {
    final timestamp = StorageService.settingsBox.get(_timestampKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp as String);
  }

  Future<void> _setLastBackupTime(DateTime time) async {
    await StorageService.settingsBox.put(_timestampKey, time.toIso8601String());
  }

  /// Delete the local backup record (clears the last backup time)
  Future<bool> deleteBackup() async {
    try {
      await StorageService.settingsBox.delete(_timestampKey);
      return true;
    } catch (e) {
      debugPrint('LOCAL_BACKUP_SERVICE deleteBackup ERROR: $e');
      return false;
    }
  }

  /// Import all data to local storage (APPEND logic)
  Future<void> _importAllData(Map<String, dynamic> data) async {
    // Import categories (Dependencies)
    final categories = data['categories'] as List<dynamic>? ?? [];
    for (var categoryData in categories) {
      final category = _categoryFromJson(categoryData as Map<String, dynamic>);
      if (!StorageService.categoryBox.containsKey(category.id)) {
        await StorageService.categoryBox.put(category.id, category);
      }
    }

    // Import persons (Dependencies for debts)
    final persons = data['persons'] as List<dynamic>? ?? [];
    for (var personData in persons) {
      final person = _personFromJson(personData as Map<String, dynamic>);
      if (!StorageService.personBox.containsKey(person.id)) {
        await StorageService.personBox.put(person.id, person);
      }
    }

    // Import expenses
    final expenses = data['expenses'] as List<dynamic>? ?? [];
    for (var expenseData in expenses) {
      final expense = _expenseFromJson(expenseData as Map<String, dynamic>);
      if (!StorageService.expenseBox.containsKey(expense.id)) {
        await StorageService.expenseBox.put(expense.id, expense);
      }
    }

    // Import shortcuts
    final shortcuts = data['shortcuts'] as List<dynamic>? ?? [];
    for (var shortcutData in shortcuts) {
      final shortcut = _shortcutFromJson(shortcutData as Map<String, dynamic>);
      if (!StorageService.shortcutBox.containsKey(shortcut.id)) {
        await StorageService.shortcutBox.put(shortcut.id, shortcut);
      }
    }

    // Import debts
    final debts = data['debts'] as List<dynamic>? ?? [];
    for (var debtData in debts) {
      final debt = _debtFromJson(debtData as Map<String, dynamic>);
      if (!StorageService.debtBox.containsKey(debt.id)) {
        await StorageService.debtBox.put(debt.id, debt);
      }
    }

    // Import budgets
    final budgets = data['budgets'] as List<dynamic>? ?? [];
    for (var budgetData in budgets) {
      final budget = _budgetFromJson(budgetData as Map<String, dynamic>);
      if (!StorageService.budgetBox.containsKey(budget.id)) {
        await StorageService.budgetBox.put(budget.id, budget);
      }
    }

    // Import shopping lists
    final shoppingLists = data['shopping_lists'] as List<dynamic>? ?? [];
    for (var listData in shoppingLists) {
      final list = _shoppingListFromJson(listData as Map<String, dynamic>);
      if (!StorageService.shoppingListBox.containsKey(list.id)) {
        await StorageService.shoppingListBox.put(list.id, list);
      }
    }

    // Import processed SMS IDs (Metatdata)
    final processedSms = data['processed_sms'] as List<dynamic>? ?? [];
    for (var smsId in processedSms) {
      if (smsId is String &&
          !StorageService.processedSmsBox.containsKey(smsId)) {
        await StorageService.processedSmsBox.put(smsId, smsId);
      }
    }
  }

  /// Export all data from local storage
  Future<Map<String, dynamic>> _exportAllData() async {
    return {
      'version': '1.1.0',
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
              'personId': d.personId,
              'reason': d.reason,
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
      'shopping_lists': StorageService.shoppingListBox.values
          .map(
            (l) => {
              'id': l.id,
              'name': l.name,
              'dateCreated': l.dateCreated.toIso8601String(),
              'items': l.items
                  .map(
                    (i) => {
                      'id': i.id,
                      'name': i.name,
                      'isCompleted': i.isCompleted,
                      'estimatedCost': i.estimatedCost,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'persons': StorageService.personBox.values
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'createdAt': p.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'processed_sms': StorageService.processedSmsBox.values.toList(),
    };
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
      personId: json['personId'] as String?,
      reason: json['reason'] as String? ?? '',
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

  ShoppingListModel _shoppingListFromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      items: (json['items'] as List<dynamic>)
          .map((i) => _shoppingItemFromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  ShoppingItemModel _shoppingItemFromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,
    );
  }

  PersonModel _personFromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
