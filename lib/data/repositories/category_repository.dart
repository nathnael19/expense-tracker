import 'package:lucide_icons_flutter/lucide_icons.dart';
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
          iconCode: LucideIcons.utensils.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Shopping',
          iconCode: LucideIcons.shoppingBag.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Transport',
          iconCode: LucideIcons.car.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Entertainment',
          iconCode: LucideIcons.film.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Housing',
          iconCode: LucideIcons.house.codePoint,
        ),
        CategoryModel(
          id: const Uuid().v4(),
          name: 'Health',
          iconCode: LucideIcons.activity.codePoint,
        ),
        CategoryModel(
          id: 'uncategorized',
          name: 'Uncategorized',
          iconCode: LucideIcons.circle.codePoint,
        ),
      ];

      for (var cat in defaults) {
        await addCategory(cat);
      }
    }
  }
}
