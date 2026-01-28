import 'package:hive/hive.dart';
import 'shopping_item_model.dart';

part 'shopping_list_model.g.dart';

@HiveType(typeId: 9)
class ShoppingListModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<ShoppingItemModel> items;

  @HiveField(3)
  final DateTime dateCreated;

  ShoppingListModel({
    required this.id,
    required this.name,
    required this.items,
    required this.dateCreated,
  });

  ShoppingListModel copyWith({
    String? id,
    String? name,
    List<ShoppingItemModel>? items,
    DateTime? dateCreated,
  }) {
    return ShoppingListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
