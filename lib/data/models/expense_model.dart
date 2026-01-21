import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 5)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

@HiveType(typeId: 7)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
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

  @HiveField(6)
  final RecurrenceType? recurrence;

  @HiveField(7)
  final DateTime? lastGeneratedDate;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    this.type = TransactionType.expense,
    this.recurrence = RecurrenceType.none,
    this.lastGeneratedDate,
  });

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    TransactionType? type,
    RecurrenceType? recurrence,
    DateTime? lastGeneratedDate,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
    );
  }
}
