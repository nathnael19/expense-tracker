import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/shortcut_model.dart';
import '../../blocs/shortcut_cubit.dart';

class AddShortcutDialog extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialAmount;
  final String? initialNote;

  const AddShortcutDialog({
    super.key,
    this.initialCategoryId,
    this.initialAmount,
    this.initialNote,
  });

  @override
  State<AddShortcutDialog> createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends State<AddShortcutDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController(text: widget.initialAmount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Shortcut'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title (e.g. Coffee)'),
            autofocus: true,
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Default Amount'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty ||
                _amountController.text.isEmpty ||
                widget.initialCategoryId == null) {
              return;
            }

            final newShortcut = ShortcutModel(
              id: const Uuid().v4(),
              title: _titleController.text.trim(),
              amount: double.tryParse(_amountController.text) ?? 0,
              categoryId: widget.initialCategoryId!,
              note: (widget.initialNote ?? '').isNotEmpty ? widget.initialNote : null,
            );

            context.read<ShortcutCubit>().addShortcut(newShortcut);
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
