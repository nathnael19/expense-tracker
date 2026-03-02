import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../data/models/category_model.dart';

class CategoryDetailSheet extends StatelessWidget {
  final CategoryModel category;
  final List<dynamic> expenses;
  final Color color;

  const CategoryDetailSheet({
    super.key,
    required this.category,
    required this.expenses,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconData(
                    category.iconCode,
                    fontFamily: 'Lucide',
                    fontPackage: 'lucide_icons_flutter',
                  ),
                  color: color,
                ),
              ),
              const Gap(12),
              Text(
                category.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${expenses.length} items',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Gap(20),
          Flexible(
            child: expenses.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: expenses.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final e = expenses[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          e.note.isEmpty ? 'No description' : e.note,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().format(e.date),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          'ETB ${e.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
