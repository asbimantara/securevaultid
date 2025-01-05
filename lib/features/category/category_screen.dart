import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 0, // Akan diupdate dengan data sebenarnya
        itemBuilder: (context, index) {
          return const CategoryCard();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add category screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to category detail
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder, size: 48),
            SizedBox(height: 8),
            Text('Nama Kategori'),
            Text('0 Password', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
