import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/shopping_cubit.dart';
import '../blocs/shopping_state.dart';
import '../../data/models/shopping_list_model.dart';
import '../../data/models/shopping_item_model.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingListModel list;

  const ShoppingListDetailScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        // Find the current list in the state
        ShoppingListModel? currentList;
        if (state is ShoppingLoaded) {
          currentList = state.lists.firstWhere(
            (l) => l.id == list.id,
            orElse: () => list,
          );
        } else {
          currentList = list;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              currentList.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: currentList.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This list is empty',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: currentList.items.length,
                  itemBuilder: (context, index) {
                    final item = currentList!.items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        context.read<ShoppingCubit>().removeItemFromList(
                          currentList!.id,
                          item.id,
                        );
                      },
                      child: ListTile(
                        leading: Checkbox(
                          value: item.isCompleted,
                          onChanged: (_) {
                            context.read<ShoppingCubit>().toggleItemCompletion(
                              currentList!.id,
                              item.id,
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isCompleted ? Colors.grey : null,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            context.read<ShoppingCubit>().removeItemFromList(
                              currentList!.id,
                              item.id,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(context, currentList!.id),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context, String listId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Item name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<ShoppingCubit>().addItemToList(listId, value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ShoppingCubit>().addItemToList(
                  listId,
                  controller.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
