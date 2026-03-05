import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_offline/data/services/sms_parser.dart';
import 'package:expense_tracker_offline/data/models/expense_model.dart';

void main() {
  final timestamp = DateTime(2026, 3, 12, 10, 0);

  group('CBE Tests', () {
    test('should parse CBE credit (incoming money)', () {
      const message =
          'Dear Natnael your Account 1*****4514 has been Credited with ETB 140.00 from Wakjira Tesema, on 10/03/2026 at 12:06:50 with Ref No FT26069TJJP0 Your Current Balance is ETB 365.24.';
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 140.00);
      expect(result.description, 'From Wakjira Tesema');
      expect(result.type, TransactionType.income);
    });

    test('should parse CBE debit (outgoing transfer)', () {
      const message =
          'Dear Natnael, You have transfered ETB 75.00 to Fasil Abera on 10/03/2026 at 13:45:42 from your account 1*****4514. Your account has been debited with a S.charge of ETB 0.50 and 15% and VAT(15%) of ETB0.08 and Disaster Fund (5%) of ETB0.03, with a total of ETB 75.61.';
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 75.00);
      expect(result.description, 'To Fasil Abera');
      expect(result.type, TransactionType.expense);
    });
  });

  group('Telebirr Tests', () {
    test('should parse Telebirr transfer out', () {
      const message =
          'Dear Nathnael \nYou have transferred ETB 500.00 to mulugeta abeje (2519****0460) on 06/03/2026 17:51:29. Your transaction number is DC69HPJTZ9. The service fee is  ETB 1.74 and  15% VAT on the service fee is ETB 0.26. Your current E-Money Account  balance is ETB 50.70.';
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 500.00);
      expect(result.description, 'To Mulugeta Abeje');
      expect(result.type, TransactionType.expense);
    });
  });

  group('MPesa Tests', () {
    test('should parse MPesa data bundle purchase', () {
      const message =
          'You have successfully puchased Unlimted data @85 ETB_24 hrs.  Expiry date: 18-02-2026 20:20';
      final result = SmsParser.parse(message, timestamp);

      expect(result, isNotNull);
      expect(result!.amount, 85.00);
      expect(result.description, 'Unlimted Data');
      expect(result.type, TransactionType.expense);
    });
  });

  group('Non-Transaction Messages', () {
    test('should return null for non-transaction message', () {
      const message = 'Hello, how are you? Let\'s meet at 5 PM.';
      final result = SmsParser.parse(message, timestamp);
      expect(result, isNull);
    });

    test('should return null for OTP message', () {
      const message = 'Your OTP code is 123456. Do not share it with anyone.';
      final result = SmsParser.parse(message, timestamp);
      expect(result, isNull);
    });
  });
}
