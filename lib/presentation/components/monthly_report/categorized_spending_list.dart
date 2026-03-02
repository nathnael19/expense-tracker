import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../data/models/category_model.dart';

class CategorizedSpendingList extends StatelessWidget {
  final List<String> sortedCatKeys;
  final Map<String, double> categoryTotals;
  final List<CategoryModel> categories;
  final double totalSpent;
  final List<Color> colors;
  final Function(CategoryModel, List<dynamic>, Color) onCategoryTap;
  final List<dynamic> expenses;

  const CategorizedSpendingList({
    super.key,
    required this.sortedCatKeys,
    required this.categoryTotals,
    required this.categories,
    required this.totalSpent,
    required this.colors,
    required this.onCategoryTap,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    if (sortedCatKeys.isEmpty) {
      return const Center(child: Text('No categories to display'));
    }

    return Column(
      children: sortedCatKeys.map((catId) {
        final val = categoryTotals[catId]!;
        final cat = categories.where((c) => c.id == catId).firstOrNull ??
            CategoryModel(
              id: 'unknown',
              name: 'Unknown',
              iconCode: 0xe88e,
            );
        final index = sortedCatKeys.indexOf(catId);
        final color = colors[index % colors.length];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              final catExpenses = expenses.where((e) => e.categoryId == catId).toList();
              onCategoryTap(cat, catExpenses, color);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconData(
                        cat.iconCode,
                        fontFamily: 'Lucide',
                        fontPackage: 'lucide_icons_flutter',
                      ),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: totalSpent > 0 ? val / totalSpent : 0,
                            backgroundColor: Colors.grey[100],
                            color: color,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'ETB ${val.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
