import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/shopping_list_model.dart';
import '../../data/models/shopping_item_model.dart';
import '../../data/repositories/shopping_repository.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final ShoppingRepository _repository;
  final _uuid = const Uuid();

  ShoppingCubit(this._repository) : super(ShoppingInitial());

  void loadShoppingLists() {
    emit(ShoppingLoading());
    try {
      final lists = _repository.getAllShoppingLists();
      emit(ShoppingLoaded(lists));
    } catch (e) {
      emit(ShoppingError('Failed to load shopping lists: ${e.toString()}'));
    }
  }

  Future<void> addShoppingList(String name) async {
    final newList = ShoppingListModel(
      id: _uuid.v4(),
      name: name,
      items: [],
      dateCreated: DateTime.now(),
    );
    try {
      await _repository.addShoppingList(newList);
      loadShoppingLists();
    } catch (e) {
      emit(ShoppingError('Failed to add shopping list: ${e.toString()}'));
    }
  }

  Future<void> deleteShoppingList(String id) async {
    try {
      await _repository.deleteShoppingList(id);
      loadShoppingLists();
    } catch (e) {
      emit(ShoppingError('Failed to delete shopping list: ${e.toString()}'));
    }
  }

  Future<void> addItemToList(String listId, String itemName) async {
    if (state is ShoppingLoaded) {
      final lists = (state as ShoppingLoaded).lists;
      final listIndex = lists.indexWhere((l) => l.id == listId);
      if (listIndex != -1) {
        final list = lists[listIndex];
        final newItem = ShoppingItemModel(
          id: _uuid.v4(),
          name: itemName,
          isCompleted: false,
        );
        final updatedItems = List<ShoppingItemModel>.from(list.items)
          ..add(newItem);
        final updatedList = list.copyWith(items: updatedItems);

        try {
          await _repository.updateShoppingList(updatedList);
          loadShoppingLists();
        } catch (e) {
          emit(ShoppingError('Failed to add item: ${e.toString()}'));
        }
      }
    }
  }

  Future<void> toggleItemCompletion(String listId, String itemId) async {
    if (state is ShoppingLoaded) {
      final lists = (state as ShoppingLoaded).lists;
      final listIndex = lists.indexWhere((l) => l.id == listId);
      if (listIndex != -1) {
        final list = lists[listIndex];
        final itemIndex = list.items.indexWhere((i) => i.id == itemId);
        if (itemIndex != -1) {
          final updatedItems = List<ShoppingItemModel>.from(list.items);
          final item = updatedItems[itemIndex];
          updatedItems[itemIndex] = item.copyWith(
            isCompleted: !item.isCompleted,
          );

          final updatedList = list.copyWith(items: updatedItems);
          try {
            await _repository.updateShoppingList(updatedList);
            loadShoppingLists();
          } catch (e) {
            emit(ShoppingError('Failed to update item: ${e.toString()}'));
          }
        }
      }
    }
  }

  Future<void> removeItemFromList(String listId, String itemId) async {
    if (state is ShoppingLoaded) {
      final lists = (state as ShoppingLoaded).lists;
      final listIndex = lists.indexWhere((l) => l.id == listId);
      if (listIndex != -1) {
        final list = lists[listIndex];
        final updatedItems = List<ShoppingItemModel>.from(list.items)
          ..removeWhere((i) => i.id == itemId);

        final updatedList = list.copyWith(items: updatedItems);
        try {
          await _repository.updateShoppingList(updatedList);
          loadShoppingLists();
        } catch (e) {
          emit(ShoppingError('Failed to remove item: ${e.toString()}'));
        }
      }
    }
  }
}
