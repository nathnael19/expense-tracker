import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_offline/data/services/sms_parser.dart';
import 'package:expense_tracker_offline/data/models/expense_model.dart';

void main() {
  group('SmsParser Tests', () {
    final timestamp = DateTime(2026, 3, 12, 10, 0);

    test('should parse CBE POS debited message', () {
      const message = "Your account has been debited 350.00 ETB for POS purchase at Friendship Supermarket.";
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 350.00);
      expect(result.description, 'Friendship Supermarket');
      expect(result.type, TransactionType.expense);
    });

    test('should parse Telebirr payment message', () {
      const message = "You have paid 200.00 ETB to Merchant XYZ.";
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 200.00);
      expect(result.description, 'Merchant XYZ');
    });

    test('should return null for non-transaction message', () {
      const message = "Hello, how are you? Let's meet at 5 PM.";
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNull);
    });

    test('should parse message with ETB prefix', () {
      const message = "Spent ETB 150.50 at Cafe Nile.";
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 150.50);
      expect(result.description, 'Cafe Nile');
    });
  });
}
