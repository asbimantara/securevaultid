import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/models/category_model.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({
    super.key,
    this.category,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool get _isEditing => widget.category != null;

  static const int maxNameLength = 30; // Maksimal karakter untuk nama kategori

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.category!.name;
      _selectedColor = Color(widget.category!.color);
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Warna'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
              ].map((color) {
                return InkWell(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryProvider>();

    if (_isEditing) {
      // Mode edit - Update kategori yang ada
      final updatedCategory = Category(
        id: widget.category!.id,
        name: _nameController.text,
        color: _selectedColor.value,
      );
      await provider.updateCategory(updatedCategory);
    } else {
      // Mode tambah - Buat kategori baru
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        color: _selectedColor.value,
      );
      await provider.addCategory(newCategory);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Kategori berhasil diperbarui'
              : 'Kategori berhasil ditambahkan'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveCategory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: maxNameLength,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                border: const OutlineInputBorder(),
                counterText: '${_nameController.text.length}/$maxNameLength',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Warna'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: _showColorPicker,
            ),
          ],
        ),
      ),
    );
  }
}
