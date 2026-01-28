import 'package:hive/hive.dart';

part 'shopping_item_model.g.dart';

@HiveType(typeId: 8)
class ShoppingItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isCompleted;

  ShoppingItemModel({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  ShoppingItemModel copyWith({String? id, String? name, bool? isCompleted}) {
    return ShoppingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
