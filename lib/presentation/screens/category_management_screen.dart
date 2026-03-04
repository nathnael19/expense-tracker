import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/category_cubit.dart';
import '../components/category_management/category_dialog.dart';
import '../components/category_management/category_list_tile.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state;

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
                return CategoryListTile(category: categories[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (ctx) => const CategoryDialog(),
        ),
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
