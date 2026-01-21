import 'package:hive/hive.dart';

part 'shortcut_model.g.dart';

@HiveType(typeId: 2)
class ShortcutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final String? note;

  ShortcutModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    this.note,
  });
}
