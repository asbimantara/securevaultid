import 'package:hive/hive.dart';
import '../models/password_model.dart';
import '../../core/utils/encryption_util.dart';

class PasswordRepository {
  static const String _boxName = 'passwords';
  late Box<Password> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Password>(_boxName);
  }

  Future<List<Password>> getAllPasswords() async {
    return _box.values.toList();
  }

  Future<Password?> getPassword(String id) async {
    return _box.get(id);
  }

  Future<void> savePassword(Password password) async {
    await _box.put(password.id, password);
  }

  Future<void> updatePassword(Password password) async {
    if (_box.containsKey(password.id)) {
      await _box.put(password.id, password);
    }
  }

  Future<void> deletePassword(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  Future<List<Password>> searchPasswords(String query) async {
    query = query.toLowerCase();
    return _box.values
        .where((password) =>
            password.title.toLowerCase().contains(query) ||
            password.username.toLowerCase().contains(query) ||
            (password.notes?.toLowerCase() ?? '').contains(query))
        .toList();
  }

  Future<List<Password>> getPasswordsByCategory(String categoryId) async {
    return _box.values
        .where((password) => password.categoryId == categoryId)
        .toList();
  }

  Future<void> importPasswords(List<Password> passwords) async {
    final Map<String, Password> entries = {
      for (var password in passwords) password.id: password
    };
    await _box.putAll(entries);
  }

  Future<void> close() async {
    await _box.close();
  }
}
