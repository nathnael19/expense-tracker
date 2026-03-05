import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../local/storage_service.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import 'sms_parser.dart';
import 'notification_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('com.nathnael19.expense_tracker_offline/sms');
  static const EventChannel _eventChannel = EventChannel('com.nathnael19.expense_tracker_offline/sms_stream');

  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  /// Request SMS permissions from Android.
  Future<bool> requestPermissions() async {
    try {
      final bool granted = await _channel.invokeMethod('requestSmsPermissions');
      return granted;
    } catch (e) {
      return false;
    }
  }

  /// Start listening for incoming SMS via the event channel.
  void init() {
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        final body = event['body'] as String?;
        final address = event['address'] as String?;
        final date = event['date'] as int?;
        if (body != null) {
          _onSmsReceived(body: body, address: address, date: date);
        }
      }
    });
  }

  Future<void> _onSmsReceived({required String body, String? address, int? date}) async {
    // 1. Check if SMS detection is enabled in settings
    final isEnabled = StorageService.settingsBox.get('smsDetectionEnabled', defaultValue: false);
    if (!isEnabled) return;

    // 2. Duplicate Protection (Hash of message body + address + timestamp)
    final msgId = _generateMsgId(body: body, address: address, date: date);
    if (StorageService.processedSmsBox.containsKey(msgId)) return;

    // 3. Parse Message
    final timestamp = DateTime.fromMillisecondsSinceEpoch(date ?? DateTime.now().millisecondsSinceEpoch);
    final parsed = SmsParser.parse(body, timestamp);
    if (parsed == null) return;

    // 4. Get "Uncategorized" Category
    final categories = _categoryRepository.getAllCategories();
    final uncategorized = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'uncategorized',
      orElse: () => categories.first,
    );

    // 5. Create Expense
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      amount: parsed.amount,
      categoryId: uncategorized.id,
      note: parsed.description,
      date: parsed.date,
      type: parsed.type,
    );

    // 6. Save Expense
    await _expenseRepository.addExpense(expense);

    // 7. Mark as processed
    await StorageService.processedSmsBox.put(msgId, msgId);

    // 8. Show Notification
    await NotificationService.showNotification(
      id: msgId.hashCode,
      title: 'New Transaction Detected',
      body: 'Added ${parsed.amount} ETB for ${parsed.description}',
    );
  }

  String _generateMsgId({required String body, String? address, int? date}) {
    final input = '${body}_${address}_$date';
    return sha256.convert(utf8.encode(input)).toString();
  }
}
