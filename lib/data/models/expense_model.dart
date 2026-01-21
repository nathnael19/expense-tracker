import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 5)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String note;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final TransactionType type;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    this.type = TransactionType.expense,
  });
}
