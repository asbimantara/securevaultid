import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/models/category_model.dart';
import 'category_form_screen.dart';

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryFormScreen(),
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
}

class CategoryListItem extends StatelessWidget {
  final Category category;

  const CategoryListItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color,
          child: Icon(
            IconData(
              int.parse(category.icon),
              fontFamily: 'MaterialIcons',
            ),
            color: Colors.white,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(category.description ?? ''),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryFormScreen(
                      category: category,
                    ),
                  ),
                );
              },
            ),
            if (!category.isDefault)
              PopupMenuItem(
                child: const Text('Hapus'),
                onTap: () {
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
                            context
                                .read<CategoryProvider>()
                                .deleteCategory(category);
                            Navigator.pop(context);
                          },
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
