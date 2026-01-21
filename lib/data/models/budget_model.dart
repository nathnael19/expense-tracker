import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 6)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id; // Format: YYYY-MM or YYYY-MM-categoryID

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int month;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String? categoryId; // null for total monthly budget

  BudgetModel({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
  });
}
