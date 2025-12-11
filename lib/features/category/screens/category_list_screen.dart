// Category management

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/models/category_model.dart';
import '../../../features/category/screens/category_form_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  void _deleteCategory(BuildContext context, Category category) async {
    // Cek apakah kategori masih digunakan
    final passwords = await context
        .read<PasswordProvider>()
        .getPasswordsByCategory(category.id);

    if (context.mounted) {
      if (passwords.isNotEmpty) {
        // Jika kategori masih digunakan, tampilkan peringatan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kategori Masih Digunakan'),
            content: Text(
              'Kategori "${category.name}" masih digunakan oleh ${passwords.length} password. '
              'Hapus atau pindahkan password tersebut terlebih dahulu.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Jika kategori tidak digunakan, konfirmasi penghapusan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Kategori'),
            content: Text(
              'Anda yakin ingin menghapus kategori "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await context
                        .read<CategoryProvider>()
                        .deleteCategory(category.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kategori berhasil dihapus'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Gagal menghapus kategori: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/categories/add'),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text('Belum ada kategori'),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(category.color),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(category.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryFormScreen(category: category),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCategory(context, category),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/categories/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
