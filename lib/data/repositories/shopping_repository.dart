import '../local/storage_service.dart';
import '../models/shopping_list_model.dart';

class ShoppingRepository {
  Future<void> addShoppingList(ShoppingListModel list) async {
    await StorageService.shoppingListBox.put(list.id, list);
  }

  Future<void> updateShoppingList(ShoppingListModel list) async {
    await StorageService.shoppingListBox.put(list.id, list);
  }

  Future<void> deleteShoppingList(String id) async {
    await StorageService.shoppingListBox.delete(id);
  }

  List<ShoppingListModel> getAllShoppingLists() {
    return StorageService.shoppingListBox.values.toList()
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
  }
}
