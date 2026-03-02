import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/models/category_model.dart';
import '../../blocs/category_cubit.dart';

class CategoryDialog extends StatefulWidget {
  final CategoryModel? category;

  const CategoryDialog({super.key, this.category});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late TextEditingController _textController;
  late int _selectedIcon;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.iconCode ?? LucideIcons.circleHelp.codePoint;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category == null ? 'New Category' : 'Edit Category',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Gap(24),
                const Text('Category Name',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                const Gap(8),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Groceries',
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.3),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                  autofocus: true,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Gap(24),
                const Text('Select Icon',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.5)),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      LucideIcons.utensils,
                      LucideIcons.shoppingBag,
                      LucideIcons.car,
                      LucideIcons.house,
                      LucideIcons.banknote,
                      LucideIcons.film,
                      LucideIcons.activity,
                      LucideIcons.graduationCap,
                      LucideIcons.dumbbell,
                      LucideIcons.gift,
                      LucideIcons.briefcase,
                      LucideIcons.plane,
                      LucideIcons.coffee,
                      LucideIcons.tv,
                      LucideIcons.dog,
                      LucideIcons.piggyBank,
                      LucideIcons.partyPopper,
                      LucideIcons.monitor,
                      LucideIcons.zap,
                      LucideIcons.wrench,
                    ].map((icon) {
                      final isSelected = _selectedIcon == icon.codePoint;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon.codePoint;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[500],
                            size: 28,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Gap(32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Gap(12),
                    ElevatedButton(
                      onPressed: () {
                        final name = _textController.text.trim();
                        if (name.isEmpty) return;

                        if (widget.category == null) {
                          final newCat = CategoryModel(
                            id: const Uuid().v4(),
                            name: name,
                            iconCode: _selectedIcon,
                          );
                          context.read<CategoryCubit>().addCategory(newCat);
                        } else {
                          final updatedCat = CategoryModel(
                            id: widget.category!.id,
                            name: name,
                            iconCode: _selectedIcon,
                          );
                          context.read<CategoryCubit>().addCategory(updatedCat);
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        elevation: 0,
                      ),
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
