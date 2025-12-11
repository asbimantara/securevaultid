import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/providers/category_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category; // null untuk tambah baru, isi untuk edit

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.folder;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      // Set icon dan color dari category yang ada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Tambah Kategori' : 'Edit Kategori',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Ikon'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.folder),
                          onPressed: () =>
                              setState(() => _selectedIcon = Icons.folder),
                          color: _selectedIcon == Icons.folder
                              ? _selectedColor
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.lock),
                          onPressed: () =>
                              setState(() => _selectedIcon = Icons.lock),
                          color: _selectedIcon == Icons.lock
                              ? _selectedColor
                              : null,
                        ),
                        // Tambahkan icon lainnya
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Warna'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: [
                        _buildColorChoice(Colors.blue),
                        _buildColorChoice(Colors.red),
                        _buildColorChoice(Colors.green),
                        _buildColorChoice(Colors.orange),
                        // Tambahkan warna lainnya
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final category = Category(
                    name: _nameController.text,
                    icon: _selectedIcon.toString(),
                    color: _selectedColor.value,
                  );

                  if (widget.category == null) {
                    context.read<CategoryProvider>().addCategory(category);
                  } else {
                    category.key = widget.category!.key;
                    context.read<CategoryProvider>().updateCategory(category);
                  }

                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
