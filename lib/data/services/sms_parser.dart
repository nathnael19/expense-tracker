import 'package:expense_tracker_offline/data/models/expense_model.dart';

class ParsedSms {
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;

  ParsedSms({
    required this.amount,
    required this.description,
    required this.date,
    this.type = TransactionType.expense,
  });
}

class SmsParser {
  // --- CBE Patterns ---
  //
  // CBE Credit: "has been Credited with ETB 140.00 from Wakjira Tesema"
  static final _cbeCreditRegex = RegExp(
    r'Credited with ETB ([\d,]+\.?\d{0,2}) from (.+?)(?:,|on |at |with )',
    caseSensitive: false,
  );

  // CBE Debit (transfer out): "You have transfered ETB 75.00 to Fasil Abera"
  static final _cbeDebitRegex = RegExp(
    r'(?:transfered|transferred) ETB ([\d,]+\.?\d{0,2}) to (.+?)(?:on |at |with |\d)',
    caseSensitive: false,
  );

  // --- Telebirr Patterns ---
  //
  // Telebirr Transfer: "You have transferred ETB 500.00 to mulugeta abeje (2519****0460)"
  static final _telebirrTransferRegex = RegExp(
    r'transferred ETB ([\d,]+\.?\d{0,2}) to ([A-Za-z ]+?)\s*[\(\d]',
    caseSensitive: false,
  );

  // --- MPesa Patterns ---
  //
  // MPesa Purchase: "purchased Unlimited data @85 ETB_24 hrs" or typo "puchased"
  static final _mpesaPurchaseRegex = RegExp(
    r'pu(?:r?c)hased (.+?) @([\d,]+\.?\d{0,2}) ETB',
    caseSensitive: false,
  );

  static ParsedSms? parse(String message, DateTime timestamp) {
    // --- 1. Try CBE Credit ---
    final cbeCreditMatch = _cbeCreditRegex.firstMatch(message);
    if (cbeCreditMatch != null) {
      final amount = _parseAmount(cbeCreditMatch.group(1));
      if (amount != null) {
        return ParsedSms(
          amount: amount,
          description: 'From ${_cleanName(cbeCreditMatch.group(2)!)}',
          date: timestamp,
          type: TransactionType.income,
        );
      }
    }

    // --- 2. Try CBE / Telebirr Debit (transfer out) ---
    // Telebirr and CBE share the same "transferred ETB X to Name" pattern
    final transferMatch = _telebirrTransferRegex.firstMatch(message) ??
        _cbeDebitRegex.firstMatch(message);
    if (transferMatch != null) {
      final amount = _parseAmount(transferMatch.group(1));
      if (amount != null) {
        return ParsedSms(
          amount: amount,
          description: 'To ${_cleanName(transferMatch.group(2)!)}',
          date: timestamp,
          type: TransactionType.expense,
        );
      }
    }

    // --- 3. Try MPesa Purchase ---
    final mpesaMatch = _mpesaPurchaseRegex.firstMatch(message);
    if (mpesaMatch != null) {
      final description = mpesaMatch.group(1)?.trim() ?? 'MPesa Purchase';
      final amount = _parseAmount(mpesaMatch.group(2));
      if (amount != null) {
        return ParsedSms(
          amount: amount,
          description: _cleanName(description),
          date: timestamp,
          type: TransactionType.expense,
        );
      }
    }

    return null;
  }

  static double? _parseAmount(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', ''));
  }

  static String _cleanName(String name) {
    // Trim trailing spaces or punctuation, then title-case
    name = name.trim().replaceAll(RegExp(r'[,\s]+$'), '');
    return name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
