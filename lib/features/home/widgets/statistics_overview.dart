import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../core/utils/date_formatter.dart';

class StatisticsOverview extends StatelessWidget {
  const StatisticsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Consumer2<PasswordProvider, CategoryProvider>(
              builder: (context, passwordProvider, categoryProvider, child) {
                final totalPasswords = passwordProvider.passwords.length;
                final totalCategories = categoryProvider.categories.length;
                final weakPasswords = passwordProvider.passwords
                    .where((p) => p.password.length < 8)
                    .length;
                final lastModified = passwordProvider.passwords.isEmpty
                    ? null
                    : passwordProvider.passwords
                        .reduce((a, b) => a.lastModified!
                                .isAfter(b.lastModified ?? b.createdAt)
                            ? a
                            : b)
                        .lastModified;

                return Column(
                  children: [
                    _buildStatRow(
                      context,
                      icon: Icons.password,
                      label: 'Total Password',
                      value: totalPasswords.toString(),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      icon: Icons.category,
                      label: 'Total Kategori',
                      value: totalCategories.toString(),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      icon: Icons.warning,
                      label: 'Password Lemah',
                      value: weakPasswords.toString(),
                      valueColor:
                          weakPasswords > 0 ? Colors.orange : Colors.green,
                    ),
                    if (lastModified != null) ...[
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        icon: Icons.update,
                        label: 'Terakhir Diubah',
                        value: DateFormatter.formatRelativeDate(lastModified),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
