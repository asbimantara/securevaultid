import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Cepat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add,
                  label: 'Password Baru',
                  onTap: () => Navigator.pushNamed(context, '/password/form'),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.category,
                  label: 'Kategori',
                  onTap: () => Navigator.pushNamed(context, '/categories'),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.backup,
                  label: 'Backup',
                  onTap: () => Navigator.pushNamed(context, '/backup'),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.analytics,
                  label: 'Analisis',
                  onTap: () {
                    // TODO: Implement analytics
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
