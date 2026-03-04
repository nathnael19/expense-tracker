import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/shopping_item_model.dart';
import '../../blocs/shopping_cubit.dart';

class ShoppingItemTile extends StatelessWidget {
  final String listId;
  final ShoppingItemModel item;
  final VoidCallback onEdit;

  const ShoppingItemTile({
    super.key,
    required this.listId,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
        context.read<ShoppingCubit>().removeItemFromList(listId, item.id);
      },
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (_) {
            context.read<ShoppingCubit>().toggleItemCompletion(listId, item.id);
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
                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  color: item.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.estimatedCost != null && item.estimatedCost! > 0)
              Text(
                '${item.isCompleted ? "" : "ETB "}${item.estimatedCost?.toStringAsFixed(2)}',
                style: TextStyle(
                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  color: item.isCompleted ? Colors.grey : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onEdit,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () {
            context.read<ShoppingCubit>().removeItemFromList(listId, item.id);
          },
        ),
      ),
    );
  }
}
