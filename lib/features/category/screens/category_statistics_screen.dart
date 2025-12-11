import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/models/category_model.dart';

class CategoryStatisticsScreen extends StatelessWidget {
  const CategoryStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Kategori'),
      ),
      body: Consumer2<CategoryProvider, PasswordProvider>(
        builder: (context, categoryProvider, passwordProvider, child) {
          final categories = categoryProvider.categories;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(categories),
                const SizedBox(height: 16),
                _buildDistributionChart(categories),
                const SizedBox(height: 16),
                _buildCategoryList(categories),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Category> categories) {
    final totalPasswords = categories.fold<int>(
      0,
      (sum, category) => sum + category.passwordCount,
    );
    final avgPasswordsPerCategory =
        totalPasswords / (categories.isEmpty ? 1 : categories.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Total Kategori: ${categories.length}'),
            Text('Total Password: $totalPasswords'),
            Text(
              'Rata-rata Password per Kategori: ${avgPasswordsPerCategory.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart(List<Category> categories) {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: categories.map((category) {
            return PieChartSectionData(
              color: category.color,
              value: category.passwordCount.toDouble(),
              title:
                  '${(category.passwordCount * 100 / categories.fold<int>(0, (sum, c) => sum + c.passwordCount)).toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    final sortedCategories = List<Category>.from(categories)
      ..sort((a, b) => b.passwordCount.compareTo(a.passwordCount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Kategori',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedCategories.map(
          (category) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: category.color,
                child: Icon(
                  category.icon,
                  color: Colors.white,
                ),
              ),
              title: Text(category.name),
              subtitle: Text('${category.passwordCount} password'),
              trailing: Text(
                '${(category.passwordCount * 100 / categories.fold<int>(0, (sum, c) => sum + c.passwordCount)).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
