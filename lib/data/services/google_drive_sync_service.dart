import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'google_auth_service.dart';
import '../local/storage_service.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/shortcut_model.dart';
import '../models/debt_model.dart';
import '../models/budget_model.dart';

class GoogleDriveSyncService {
  static final GoogleDriveSyncService _instance =
      GoogleDriveSyncService._internal();
  factory GoogleDriveSyncService() => _instance;
  GoogleDriveSyncService._internal();

  final GoogleAuthService _authService = GoogleAuthService();
  static const String _backupFileName = 'expense_tracker_backup.json';
  static const String _timestampKey = 'last_sync_timestamp';

  /// Upload all local data to Google Drive
  Future<bool> uploadData() async {
    try {
      if (!_authService.isSignedIn()) {
        throw Exception('User not signed in');
      }

      // Get all local data
      final data = await _exportAllData();

      // Get authenticated client
      final client = await _authService.getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      // Check if backup file already exists
      final existingFile = await _findBackupFile(driveApi);

      final jsonData = jsonEncode(data);
      final mediaStream = http.ByteStream.fromBytes(utf8.encode(jsonData));
      final media = drive.Media(mediaStream, jsonData.length);

      if (existingFile != null) {
        // Update existing file
        await driveApi.files.update(
          drive.File(),
          existingFile.id!,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await driveApi.files.create(driveFile, uploadMedia: media);
      }

      // Store sync timestamp
      await _setLastSyncTime(DateTime.now());

      client.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Download data from Google Drive
  Future<Map<String, dynamic>?> downloadData() async {
    try {
      if (!_authService.isSignedIn()) {
        throw Exception('User not signed in');
      }

      final client = await _authService.getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      // Find backup file
      final backupFile = await _findBackupFile(driveApi);
      if (backupFile == null) {
        client.close();
        return null;
      }

      // Download file content
      final response =
          await driveApi.files.get(
                backupFile.id!,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final dataBytes = <int>[];
      await for (var chunk in response.stream) {
        dataBytes.addAll(chunk);
      }

      final jsonString = utf8.decode(dataBytes);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      client.close();
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Smart sync: compare timestamps and merge data
  Future<bool> syncData() async {
    try {
      if (!_authService.isSignedIn()) {
        throw Exception('User not signed in');
      }

      // Download cloud data
      final cloudData = await downloadData();

      if (cloudData == null) {
        // No cloud backup exists, upload local data
        return await uploadData();
      }

      // Get local data
      final localData = await _exportAllData();

      // Compare timestamps
      final cloudTimestamp = DateTime.parse(
        cloudData['timestamp'] as String? ?? '2000-01-01T00:00:00Z',
      );
      final localTimestamp = DateTime.parse(
        localData['timestamp'] as String? ?? '2000-01-01T00:00:00Z',
      );

      if (cloudTimestamp.isAfter(localTimestamp)) {
        // Cloud is newer, restore from cloud
        await _importAllData(cloudData);
        await _setLastSyncTime(cloudTimestamp);
        return true;
      } else {
        // Local is newer or same, upload to cloud
        return await uploadData();
      }
    } catch (e) {
      return false;
    }
  }

  /// Restore data from Google Drive (overwrite local)
  Future<bool> restoreFromCloud() async {
    try {
      final cloudData = await downloadData();
      if (cloudData == null) {
        return false;
      }

      await _importAllData(cloudData);
      await _setLastSyncTime(DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete backup from Google Drive
  Future<bool> deleteBackup() async {
    try {
      if (!_authService.isSignedIn()) {
        throw Exception('User not signed in');
      }

      final client = await _authService.getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      final backupFile = await _findBackupFile(driveApi);
      if (backupFile != null) {
        await driveApi.files.delete(backupFile.id!);
      }

      client.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = StorageService.settingsBox.get(_timestampKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp as String);
  }

  /// Find backup file in Google Drive
  Future<drive.File?> _findBackupFile(drive.DriveApi driveApi) async {
    final response = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id, name, modifiedTime)',
    );

    if (response.files != null && response.files!.isNotEmpty) {
      return response.files!.first;
    }
    return null;
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

  /// Set last sync timestamp
  Future<void> _setLastSyncTime(DateTime time) async {
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
