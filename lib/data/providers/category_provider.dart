import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;
  List<Category> _categories = [];
  bool _isLoading = false;

  CategoryProvider(this._repository);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory(Category category) async {
    await _repository.saveCategory(category);
    await loadCategories();
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.saveCategory(category);
    await loadCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}
