import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../blocs/category_cubit.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state;

    void showCategoryDialog({CategoryModel? category}) {
      final textController = TextEditingController(text: category?.name ?? '');
      int selectedIcon = category?.iconCode ?? 0xe88e; // Default icon

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(category == null ? 'New Category' : 'Edit Category'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g. Shopping',
                    ),
                    autofocus: true,
                  ),
                  const Gap(16),
                  // Modern Icon Picker
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return GridView.count(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children:
                            [
                                  Icons.restaurant,
                                  Icons.shopping_bag,
                                  Icons.directions_car,
                                  Icons.home,
                                  Icons.payments,
                                  Icons.movie,
                                  Icons.medical_services,
                                  Icons.school,
                                  Icons.fitness_center,
                                  Icons.card_giftcard,
                                  Icons.work,
                                  Icons.flight,
                                  Icons.local_cafe,
                                  Icons.subscriptions,
                                  Icons.pets,
                                  Icons.savings,
                                  Icons.celebration,
                                  Icons.computer,
                                  Icons.electrical_services,
                                  Icons.home_repair_service,
                                ]
                                .map(
                                  (icon) => InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        selectedIcon = icon.codePoint;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedIcon == icon.codePoint
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedIcon == icon.codePoint
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: selectedIcon == icon.codePoint
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isEmpty) return;

                if (category == null) {
                  // Add
                  final newCat = CategoryModel(
                    id: const Uuid().v4(),
                    name: name,
                    iconCode: selectedIcon,
                  );
                  context.read<CategoryCubit>().addCategory(newCat);
                } else {
                  // Edit (Add logic needed in provider, for now delete/add or just overwrite)
                  // Hive object save() updates itself if using HiveObject?
                  // But we use repository put(id, obj).
                  final updatedCat = CategoryModel(
                    id: category.id,
                    name: name,
                    iconCode:
                        selectedIcon, // Keep old icon or update if we had picker
                  );
                  context.read<CategoryCubit>().addCategory(updatedCat);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories'), elevation: 0),
      body: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const Divider(height: 1),
        itemBuilder: (ctx, index) {
          final cat = categories[index];
          return ListTile(
            leading: Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons')),
            title: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: () => showCategoryDialog(category: cat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                  onPressed: () {
                    context.read<CategoryCubit>().deleteCategory(cat.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
