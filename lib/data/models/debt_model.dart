import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 4)
enum DebtType {
  @HiveField(0)
  lent,
  @HiveField(1)
  borrowed,
}

@HiveType(typeId: 3)
class DebtModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final DateTime? dueDate;

  @HiveField(5)
  final bool isPaid;

  @HiveField(6)
  final String note;

  @HiveField(7)
  final DebtType type;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.date,
    this.dueDate,
    this.isPaid = false,
    this.note = '',
    this.type = DebtType.lent,
  });

  DebtModel copyWith({
    String? id,
    String? personName,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    bool? isPaid,
    String? note,
    DebtType? type,
  }) {
    return DebtModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }
}
