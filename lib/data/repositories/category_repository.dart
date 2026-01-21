import 'package:flutter/material.dart';
import '../local/storage_service.dart';
import '../models/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final StorageService _storageService = StorageService();

  Future<void> addCategory(CategoryModel category) async {
    await _storageService.addCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await _storageService.deleteCategory(id);
  }

  List<CategoryModel> getAllCategories() {
    return _storageService.getAllCategories();
  }

  Future<void> initDefaultCategories() async {
    if (getAllCategories().isEmpty) {
      final defaults = [
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Food',
          iconCode: Icons.restaurant.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Shopping',
          iconCode: Icons.shopping_bag.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Transport',
          iconCode: Icons.directions_car.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Entertainment',
          iconCode: Icons.movie.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Housing',
          iconCode: Icons.home.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Health',
          iconCode: Icons.medical_services.codePoint,
        ),
      ];

      for (var cat in defaults) {
        await addCategory(cat);
      }
    }
  }
}
