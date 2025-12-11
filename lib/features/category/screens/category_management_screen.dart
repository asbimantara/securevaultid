// Implementasi manajemen kategori yang lebih lengkap
// - Custom colors
// - Icons selection
// - Category statistics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/models/category_model.dart';
import '../widgets/icon_picker_dialog.dart';
import '../widgets/color_picker_dialog.dart';
import '../screens/category_statistics_screen.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryForm(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryStatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return CategoryListItem(category: category);
            },
          );
        },
      ),
    );
  }

  void _showCategoryForm(BuildContext context, [Category? category]) {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(category: category),
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final Category category;

  const CategoryListItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color,
        child: Icon(
          category.icon,
          color: Colors.white,
        ),
      ),
      title: Text(category.name),
      subtitle: Text(
        category.description ?? 'Tidak ada deskripsi',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${category.passwordCount} password'),
          if (!category.isDefault)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      onTap: () => _showCategoryForm(context, category),
    );
  }

  void _showCategoryForm(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(category: category),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: const Text(
          'Anda yakin ingin menghapus kategori ini? '
          'Password yang menggunakan kategori ini akan dipindahkan ke kategori default.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
