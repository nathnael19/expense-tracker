import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/shopping_list_model.dart';
import '../../blocs/shopping_cubit.dart';

class AddShoppingListDialog extends StatefulWidget {
  final ShoppingListModel? list;

  const AddShoppingListDialog({super.key, this.list});

  @override
  State<AddShoppingListDialog> createState() => _AddShoppingListDialogState();
}

class _AddShoppingListDialogState extends State<AddShoppingListDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.list?.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      if (widget.list != null) {
        context.read<ShoppingCubit>().renameShoppingList(widget.list!.id, value);
      } else {
        context.read<ShoppingCubit>().addShoppingList(value);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.list != null;

    return AlertDialog(
      title: Text(isEditing ? 'Rename List' : 'New Shopping List'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter list name',
          border: const OutlineInputBorder(),
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[100],
          filled: true,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
