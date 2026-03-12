import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/models/category_model.dart';
import '../blocs/category_cubit.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state;

    void showCategoryDialog({CategoryModel? category}) {
      final textController = TextEditingController(text: category?.name ?? '');
      int selectedIcon =
          category?.iconCode ??
          LucideIcons.circleHelp.codePoint; // Default icon

      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
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
                      category == null ? 'New Category' : 'Edit Category',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(24),
                    const Text(
                      'Category Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Groceries',
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Gap(24),
                    const Text(
                      'Select Icon',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const Gap(12),
                    StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children:
                                [
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
                                  final isSelected =
                                      selectedIcon == icon.codePoint;
                                  return InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        selectedIcon = icon.codePoint;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.grey[500],
                                        size: 28,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        );
                      },
                    ),
                    const Gap(32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Gap(12),
                        ElevatedButton(
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isEmpty) return;

                            if (category == null) {
                              final newCat = CategoryModel(
                                id: const Uuid().v4(),
                                name: name,
                                iconCode: selectedIcon,
                              );
                              context.read<CategoryCubit>().addCategory(newCat);
                            } else {
                              final updatedCat = CategoryModel(
                                id: category.id,
                                name: name,
                                iconCode: selectedIcon,
                              );
                              context.read<CategoryCubit>().addCategory(
                                updatedCat,
                              );
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                'No categories yet.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (ctx, index) {
                final cat = categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        IconData(
                          cat.iconCode,
                          fontFamily: 'Lucide',
                          fontPackage: 'lucide_icons_flutter',
                        ),
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => showCategoryDialog(category: cat),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Delete Category?'),
                                  content: Text(
                                    'Are you sure you want to delete ${cat.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                context.read<CategoryCubit>().deleteCategory(
                                  cat.id,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryDialog(),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text(
          'New Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
