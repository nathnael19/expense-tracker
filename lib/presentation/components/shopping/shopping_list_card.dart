import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/shopping_list_model.dart';
import '../../blocs/shopping_cubit.dart';
import '../../screens/shopping_list_detail_screen.dart';

class ShoppingListCard extends StatelessWidget {
  final ShoppingListModel list;
  final VoidCallback onEdit;

  const ShoppingListCard({
    super.key,
    required this.list,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final completedCount = list.items.where((i) => i.isCompleted).length;
    final totalCount = list.items.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final totalEstimatedCost = list.items.fold<double>(
      0,
      (sum, item) => sum + (item.estimatedCost ?? 0.0),
    );

    return Dismissible(
      key: ValueKey(list.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<ShoppingCubit>().deleteShoppingList(list.id);
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingListDetailScreen(list: list),
              ),
            );
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  list.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (totalEstimatedCost > 0)
                Text(
                  'ETB ${totalEstimatedCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount of $totalCount items completed',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(list.dateCreated),
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
