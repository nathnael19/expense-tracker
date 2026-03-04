import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/shopping_item_model.dart';
import '../../blocs/shopping_cubit.dart';

class AddShoppingItemDialog extends StatefulWidget {
  final String listId;
  final ShoppingItemModel? item;

  const AddShoppingItemDialog({
    super.key,
    required this.listId,
    this.item,
  });

  @override
  State<AddShoppingItemDialog> createState() => _AddShoppingItemDialogState();
}

class _AddShoppingItemDialogState extends State<AddShoppingItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.name);
    _costController = TextEditingController(
      text: widget.item?.estimatedCost != null && widget.item!.estimatedCost! > 0
          ? widget.item!.estimatedCost!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      final estimatedCost = double.tryParse(_costController.text) ?? 0.0;
      if (widget.item != null) {
        context.read<ShoppingCubit>().editItemInList(
              widget.listId,
              widget.item!.id,
              title,
              newEstimatedCost: estimatedCost,
            );
      } else {
        context.read<ShoppingCubit>().addItemToList(
              widget.listId,
              title,
              estimatedCost: estimatedCost,
            );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Item' : 'Add Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Item name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _costController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Estimated cost (optional)',
              prefixText: 'ETB ',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
