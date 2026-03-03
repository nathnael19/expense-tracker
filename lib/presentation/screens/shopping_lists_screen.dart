import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/shopping_cubit.dart';
import '../blocs/shopping_state.dart';
import '../../data/models/shopping_list_model.dart';
import '../components/shopping/shopping_list_card.dart';
import '../components/shopping/add_shopping_list_dialog.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<ShoppingCubit, ShoppingState>(
        builder: (context, state) {
          if (state is ShoppingLoading) return const Center(child: CircularProgressIndicator());
          if (state is ShoppingError) return Center(child: Text(state.message));
          if (state is ShoppingLoaded) {
            final lists = state.lists;
            if (lists.isEmpty) return _buildEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return ShoppingListCard(
                  list: list,
                  onEdit: () => _showAddListDialog(context, list: list),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddListDialog(context),
        label: const Text('New List', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No shopping lists yet', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
        ],
      ),
    );
  }

  void _showAddListDialog(BuildContext context, {ShoppingListModel? list}) {
    showDialog(
      context: context,
      builder: (context) => AddShoppingListDialog(list: list),
    );
  }
}
