import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/shopping_cubit.dart';
import '../blocs/shopping_state.dart';
import '../../data/models/shopping_list_model.dart';
import '../../data/models/shopping_item_model.dart';
import '../components/shopping/shopping_item_tile.dart';
import '../components/shopping/add_shopping_item_dialog.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingListModel list;

  const ShoppingListDetailScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        final ShoppingListModel currentList = (state is ShoppingLoaded)
            ? state.lists.firstWhere((l) => l.id == list.id, orElse: () => list)
            : list;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              currentList.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: currentList.items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: currentList.items.length,
                  itemBuilder: (context, index) {
                    final item = currentList.items[index];
                    return ShoppingItemTile(
                      listId: currentList.id,
                      item: item,
                      onEdit: () => _showAddItemDialog(
                        context,
                        currentList.id,
                        item: item,
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(context, currentList.id),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'This list is empty',
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(
    BuildContext context,
    String listId, {
    ShoppingItemModel? item,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddShoppingItemDialog(listId: listId, item: item),
    );
  }
}
