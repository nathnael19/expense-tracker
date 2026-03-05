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
  // Common patterns for Ethiopian banking SMS
  // Example CBE: "Your account has been debited 350.00 ETB for POS purchase at Friendship Supermarket."
  // Example Telebirr: "You have paid 200.00 ETB to Merchant XYZ."
  
  static ParsedSms? parse(String message, DateTime timestamp) {
    final lowerMessage = message.toLowerCase();
    
    // Check if it's a transaction message
    final isTransaction = lowerMessage.contains('debited') || 
                           lowerMessage.contains('paid') || 
                           lowerMessage.contains('spent') ||
                           lowerMessage.contains('purchase') ||
                           lowerMessage.contains('withdrawn');
    
    if (!isTransaction) return null;

    // Extract amount
    // Pattern: [digits].[digits] ETB or ETB [digits].[digits]
    final amountRegex = RegExp(r'(\d+(?:\.\d{1,2})?)\s*etb|etb\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(message);
    
    if (amountMatch == null) return null;
    
    final amountStr = amountMatch.group(1) ?? amountMatch.group(2);
    if (amountStr == null) return null;
    
    final amount = double.tryParse(amountStr);
    if (amount == null) return null;

    // Extract Merchant/Description
    // Pattern for CBE POS: "at [Merchant Name]"
    // Pattern for Telebirr: "to [Merchant Name]"
    String description = "SMS Transaction";
    final merchantRegex = RegExp(r'(?:at|to|from)\s+([a-zA-Z0-9\s]+?)(?:\.|\s+on|\s+at|\s+your|$)', caseSensitive: false);
    final merchantMatch = merchantRegex.firstMatch(message);
    
    if (merchantMatch != null) {
      description = merchantMatch.group(1)!.trim();
    }

    return ParsedSms(
      amount: amount,
      description: description,
      date: timestamp,
      type: TransactionType.expense, // Default to expense for now
    );
  }
}
