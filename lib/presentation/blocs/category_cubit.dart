import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryCubit extends Cubit<List<CategoryModel>> {
  final CategoryRepository _repository = CategoryRepository();

  CategoryCubit() : super([]) {
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    await _repository.initDefaultCategories();
    _reload();
  }

  void _reload() {
    emit(_repository.getAllCategories());
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repository.addCategory(category);
    _reload();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    _reload();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
