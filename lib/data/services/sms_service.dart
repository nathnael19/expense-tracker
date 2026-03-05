import 'package:telephony/telephony.dart';
import 'package:uuid/uuid.dart';
import '../local/storage_service.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import 'sms_parser.dart';
import 'notification_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Top level function for background SMS handling
@pragma('vm:entry-point')
void backGroundMessageHandler(SmsMessage message) async {
  // Pass to SmsService for processing
  await SmsService().processMessage(message, fromBackground: true);
}

class SmsService {
  final Telephony telephony = Telephony.instance;
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  Future<void> init() async {
    final bool? result = await telephony.requestSmsPermissions;
    if (result != null && result) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          processMessage(message);
        },
        onBackgroundMessage: backGroundMessageHandler,
      );
    }
  }

  Future<void> processMessage(SmsMessage message, {bool fromBackground = false}) async {
    final body = message.body;
    if (body == null) return;

    // 1. Check if SMS detection is enabled in settings
    // In background isolate, we must ensure Hive is initialized
    if (fromBackground) {
      await StorageService.init();
    }

    final isEnabled = StorageService.settingsBox.get('smsDetectionEnabled', defaultValue: false);
    if (!isEnabled) return;

    // 2. Duplicate Protection (Hash of message body + address + timestamp)
    final msgId = _generateMsgId(message);
    if (StorageService.processedSmsBox.containsKey(msgId)) return;

    // 3. Parse Message
    final timestamp = DateTime.fromMillisecondsSinceEpoch(message.date ?? DateTime.now().millisecondsSinceEpoch);
    final parsed = SmsParser.parse(body, timestamp);
    if (parsed == null) return;

    // 4. Get or Create "Uncategorized" Category
    final categories = _categoryRepository.getAllCategories();
    var uncategorized = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'uncategorized',
      orElse: () => categories.first, // Fallback to first if not found
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
    await NotificationService.init(); // Ensure init for notification
    await NotificationService.showNotification(
      id: msgId.hashCode,
      title: 'New Transaction Detected',
      body: 'Added ${parsed.amount} ETB for ${parsed.description}',
    );
  }

  String _generateMsgId(SmsMessage message) {
    final input = '${message.body}_${message.address}_${message.date}';
    return sha256.convert(utf8.encode(input)).toString();
  }
}
