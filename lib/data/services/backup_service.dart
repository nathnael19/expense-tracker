// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../local/storage_service.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/shortcut_model.dart';

class BackupService {
  static Future<void> exportData() async {
    final expenses = StorageService.expenseBox.values
        .map(
          (e) => {
            'id': e.id,
            'amount': e.amount,
            'note': e.note,
            'date': e.date.toIso8601String(),
            'categoryId': e.categoryId,
          },
        )
        .toList();

    final categories = StorageService.categoryBox.values
        .map((c) => {'id': c.id, 'name': c.name, 'iconCode': c.iconCode})
        .toList();

    final shortcuts = StorageService.shortcutBox.values
        .map(
          (s) => {
            'id': s.id,
            'title': s.title,
            'amount': s.amount,
            'categoryId': s.categoryId,
            'note': s.note,
          },
        )
        .toList();

    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'expenses': expenses,
      'categories': categories,
      'shortcuts': shortcuts,
    };

    final jsonString = jsonEncode(data);

    final directory = await getTemporaryDirectory();
    final fileName =
        'expense_tracker_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(path)], text: 'Expense Tracker Backup');
  }

  static Future<bool> restoreData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        // Simple validation
        if (!data.containsKey('expenses') || !data.containsKey('categories')) {
          return false;
        }

        // Clear existing data
        await StorageService.expenseBox.clear();
        await StorageService.categoryBox.clear();
        await StorageService.shortcutBox.clear();

        // Restore Categories
        for (var c in data['categories']) {
          final cat = CategoryModel(
            id: c['id'],
            name: c['name'],
            iconCode: c['iconCode'],
          );
          await StorageService.categoryBox.put(cat.id, cat);
        }

        // Restore Expenses
        for (var e in data['expenses']) {
          final exp = ExpenseModel(
            id: e['id'],
            amount: e['amount'],
            note: e['note'],
            date: DateTime.parse(e['date']),
            categoryId: e['categoryId'],
          );
          await StorageService.expenseBox.put(exp.id, exp);
        }

        // Restore Shortcuts (Optional check for existence)
        if (data.containsKey('shortcuts')) {
          for (var s in data['shortcuts']) {
            final shortcut = ShortcutModel(
              id: s['id'],
              title: s['title'],
              amount: s['amount'],
              categoryId: s['categoryId'],
              note: s['note'],
            );
            await StorageService.shortcutBox.put(shortcut.id, shortcut);
          }
        }

        return true;
      }
      return false; // User cancelled
    } catch (e) {
      // In a real app, log error
      return false;
    }
  }
}
