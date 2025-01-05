import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryRepository {
  static const String _boxName = 'categories';
  late Box<Category> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Category>(_boxName);
  }

  Future<List<Category>> getAllCategories() async {
    return _box.values.toList();
  }

  Future<Category?> getCategory(String id) async {
    return _box.get(id);
  }

  Future<void> saveCategory(Category category) async {
    await _box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }
}
