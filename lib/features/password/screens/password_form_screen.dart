import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/models/password_model.dart';

class PasswordFormScreen extends StatefulWidget {
  const PasswordFormScreen({super.key});

  @override
  State<PasswordFormScreen> createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState extends State<PasswordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategoryId;
  bool _obscurePassword = true;
  bool _isEditing = false;
  Password? _password;

  // Definisi maksimal karakter
  static const int maxTitleLength = 50;
  static const int maxUsernameLength = 100;
  static const int maxPasswordLength = 100;
  static const int maxUrlLength = 200;
  static const int maxNotesLength = 500;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk update UI saat text berubah
    _titleController.addListener(() => setState(() {}));
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _urlController.addListener(() => setState(() {}));
    _notesController.addListener(() => setState(() {}));

    // Tunggu build selesai baru ambil arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final password = ModalRoute.of(context)?.settings.arguments as Password?;
      if (password != null) {
        setState(() {
          _isEditing = true;
          _password = password;
          _titleController.text = password.title;
          _usernameController.text = password.username;
          _passwordController.text = password.password;
          _urlController.text = password.url ?? '';
          _notesController.text = password.notes ?? '';
          _selectedCategoryId = password.categoryId;
        });
      }
    });

    // Tambahkan ini untuk memuat kategori saat form dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _isEditing
        ? _password!.copyWith(
            title: _titleController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            url: _urlController.text.trim(),
            notes: _notesController.text.trim(),
            categoryId: _selectedCategoryId,
            lastModified: DateTime.now(),
          )
        : Password(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            url: _urlController.text.trim(),
            notes: _notesController.text.trim(),
            categoryId: _selectedCategoryId,
            createdAt: DateTime.now(),
            lastModified: DateTime.now(),
          );

    try {
      if (_isEditing) {
        await context.read<PasswordProvider>().updatePassword(password);
        await context.read<PasswordProvider>().loadPasswords();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/passwords/detail',
            ModalRoute.withName('/home'),
            arguments: password,
          );
        }
      } else {
        await context.read<PasswordProvider>().addPassword(password);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Password' : 'Tambah Password'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePassword,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: maxTitleLength,
              decoration: InputDecoration(
                labelText: 'Judul',
                border: const OutlineInputBorder(),
                counterText: '${_titleController.text.length}/$maxTitleLength',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              maxLength: maxUsernameLength,
              decoration: InputDecoration(
                labelText: 'Username/Email',
                border: const OutlineInputBorder(),
                counterText:
                    '${_usernameController.text.length}/$maxUsernameLength',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              maxLength: maxPasswordLength,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                counterText:
                    '${_passwordController.text.length}/$maxPasswordLength',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, _) {
                final categories = categoryProvider.categories;

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tanpa Kategori'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Color(category.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(category.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              maxLength: maxUrlLength,
              decoration: InputDecoration(
                labelText: 'URL (opsional)',
                border: const OutlineInputBorder(),
                counterText: '${_urlController.text.length}/$maxUrlLength',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLength: maxNotesLength,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: const OutlineInputBorder(),
                counterText: '${_notesController.text.length}/$maxNotesLength',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
