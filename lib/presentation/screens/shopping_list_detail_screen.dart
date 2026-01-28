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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.isCompleted ? Colors.grey : null,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.estimatedCost != null &&
                                item.estimatedCost! > 0)
                              Text(
                                '${item.isCompleted ? "" : "ETB "}${item.estimatedCost?.toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.isCompleted
                                      ? Colors.grey
                                      : Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showAddItemDialog(
                                context,
                                currentList!.id,
                                item: item,
                              ),
                            ),
                          ],
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

  void _showAddItemDialog(
    BuildContext context,
    String listId, {
    ShoppingItemModel? item,
  }) {
    final titleController = TextEditingController(text: item?.name);
    final costController = TextEditingController(
      text: item?.estimatedCost != null && item!.estimatedCost! > 0
          ? item.estimatedCost!.toStringAsFixed(2)
          : '',
    );
    final isEditing = item != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Estimated cost (optional)',
                prefixText: 'ETB ',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(
                context,
                listId,
                titleController,
                costController,
                item: item,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submit(
              context,
              listId,
              titleController,
              costController,
              item: item,
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _submit(
    BuildContext context,
    String listId,
    TextEditingController title,
    TextEditingController cost, {
    ShoppingItemModel? item,
  }) {
    if (title.text.isNotEmpty) {
      final estimatedCost = double.tryParse(cost.text) ?? 0.0;
      if (item != null) {
        context.read<ShoppingCubit>().editItemInList(
          listId,
          item.id,
          title.text,
          newEstimatedCost: estimatedCost,
        );
      } else {
        context.read<ShoppingCubit>().addItemToList(
          listId,
          title.text,
          estimatedCost: estimatedCost,
        );
      }
      Navigator.pop(context);
    }
  }
}
